//
//  ViewControllerOneMovie.swift
//  movieTime
//
//  Created by mac14 on 2023/6/10.
//

import UIKit
import Alamofire
import Kanna
import NaturalLanguage
import FakeUserAgent

class ViewControllerOneMovie: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var spinnerView: UIActivityIndicatorView!
	@IBOutlet weak var spinnerLabel: UILabel!
	
	struct data_struct {
//		var date: String = ""
		var floor: String = ""
		var text = NSAttributedString()
	}
	
	@IBOutlet weak var indexTableView: UITableView!
	var backUrl = String()
	var tag = String()
	var indexes:[data_struct] = Array()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		spinnerView.hidesWhenStopped = true
		
		spinnerView.startAnimating()
		spinnerLabel.isHidden = false
		
		print("(url, tag) = (\(String(backUrl)), \(tag))")
		let queue = DispatchQueue.global(qos: .default)
		queue.async {
			DispatchQueue.main.async {
				self.load_data(backUrl: self.backUrl, tag: self.tag)
				self.indexTableView.reloadData()
				print(self.indexTableView.numberOfRows(inSection: 0))
			}
		}
    }
	
	//MARK: - html parser

	 func load_data(backUrl: String, tag: String) {
		 var totalPages = 0  // Variable to store the total number of pages

		 print("loading...")
		 self.title = tag

		 // 設定爬蟲資訊：headers & agent & url
		 var agent = String()
		 FakeUserAgent.shared.pickALot(count: 5, browser: .chrome, filter: { userAgent in
			 return userAgent.contains("Macintosh; Intel Mac OS X 10_")
		 }, completion: { result in
			 let randomIndex = Int(arc4random_uniform(UInt32(result.count)))
			 agent = result[randomIndex]
		 })
		 let headers: HTTPHeaders = [
			 "User-Agent": agent
		 ]
		 let url = "https://forum.gamer.com.tw/C.php?page=1\(backUrl)"
		 AF.request(url, headers: headers).responseString { response in

			 switch response.result {
			 case .success(let html):
				 // 成功获取到HTML数据
				 // 使用Kanna解析HTML
				 print("load successful!")
				 var doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8)
				 // 找總共的頁數
				 if let pageCountElement = doc?.xpath("//p[@class='BH-pagebtnA']/a[last()]"),
					 let pageCountString = pageCountElement.first?.text,
					 let total = Int(pageCountString)
				 {
					 totalPages = total
					 print("Total Pages: \(totalPages)")
					 
					 self.loadPage(page: 1, totalPages: totalPages, backUrl: backUrl, tag: tag, headers: headers) {
						 self.indexTableView.reloadData()
					 }
				 }
				 else
				 {
					 // Failed to retrieve the page count
					 print("Failed to retrieve the page count.")
				 }
		 
				 
				 
			 case .failure(let error):
				 // 处理错误
//				 check = false
				 print("ERROR : AF.request load failed, returning...")
				 print(error)
			 }
		 }
		 print("processing, please wait...")
	 }


	func loadPage(page: Int, totalPages: Int, backUrl: String, tag: String, headers: HTTPHeaders, completionHandler: @escaping () -> Void) {
		let randomDelay = Double(arc4random_uniform(3) + 1) // Random delay between 1 and 3 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
			print("processing page: \(page)")
			let url = "https://forum.gamer.com.tw/C.php?page=\(page)\(backUrl)"
			AF.request(url, headers: headers).responseString { response in
				var shouldContinue = true
				
				switch response.result {
				case .success(let html):
					// Successfully retrieved HTML data
					let doc = try? Kanna.HTML(html: html, encoding: .utf8)
					if doc?.xpath("/html/body/div").first?.className == "maintain" {
						print("ERROR: 伺服器錯誤 (你爬蟲爬太多次ㄌ)")
						shouldContinue = false
					} else {
						self.parsehtml(doc: doc!, tag: tag)
					}
					
				case .failure(let error):
					print("ERROR: AF.request load failed, returning...")
					print(error)
					shouldContinue = false
				}
				
				// Check if there are more pages to load
				if page < totalPages && shouldContinue {
					// Continue to the next page
					self.loadPage(page: page + 1, totalPages: totalPages, backUrl: backUrl, tag: tag, headers: headers, completionHandler: completionHandler)
				} else {
					// All pages have been processed
					self.spinnerView.stopAnimating()
					self.spinnerLabel.isHidden = true
					completionHandler()
				}
			}
		}
	}
	
	func parsehtml(doc: HTMLDocument, tag: String) {
		 
		var s = data_struct()

		// 找每一樓（不包含留言）的文章內容
		let articles = doc.xpath("//div[contains(@class, 'c-section__main c-post ')]")
//		print(articles)
		print("尋找的關鍵字：\(tag)")
		for article in articles {

			 // 提取 data-floor 属性的值
			 let dataFloor = article.xpath(".//div[@class='c-post__header__author']//a[@class='floor tippy-gpbp']").first!["data-floor"]!
			 s.floor = dataFloor
	 			print("data-floor:", dataFloor)
			 
			 // 提取 <article> 标签的文本内容
			 if let articleText = article.xpath(".//article[@class='c-article FM-P2']").first {
//	 				print("Article text:", articleText.text ?? "")
				 let ws = extractSentences(from: articleText.text!)
				 for w in ws {
					 if(w.contains(tag) && w.count < 350){ // eg. "劇情"
						 print("(\(dataFloor)) : \(w)")
						 let attributedString = NSMutableAttributedString(string: w)

						 // Set red color and bold font attributes
						 let attributes: [NSAttributedString.Key: Any] = [
//							 .font: UIFont.boldSystemFont(ofSize: 16),
							 .foregroundColor: UIColor.red
						 ]

						 // Find the range of the specified string in the original string
						 let range = (w as NSString).range(of: tag)
						 // Apply the attributes to the specified range
						 attributedString.addAttributes(attributes, range: range)
						 attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 16)], range: NSRange(location: 0, length: attributedString.length))

						 // Assign the attributed string to the label's attributedText property
						 s.text = attributedString
						 
						 indexes.append(s)
					 }
				 }
			 }
		 }
		 self.indexTableView.reloadData()
		
		 // 尋找的關鍵字沒有結果
		 if(indexes.count == 0) {
			 let alert = UIAlertController(
				 title: "錯誤",
				 message: "沒有符合「\(tag)」的文章內容",
				 preferredStyle: .alert
			 )
			 alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
			 
			 present(alert, animated: true, completion: nil)
		 }
	 }


	 //MARK: - refrence: https://qingcheng.li/play-with-nslinguistictagger-de254fd136a8

	 // 找出該句子的語言
	 func languageTest(sentence: String) {
		 let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
		 tagger.string = sentence
		 if let language = tagger.dominantLanguage {
			 print("\(language)")
		 } else {
			 print("Unknow.")
		 }
	 }

	 // 斷字
	 func tokenize(sentence: String) -> [String] {
		 var tokens:[String] = [String]()

		 let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)

		 tagger.string = sentence
		 let range = NSMakeRange(0, sentence.utf16.count)
		 let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation]

		 tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: options) { (tag, tokenRange, stop) in
			 let word = (sentence as NSString).substring(with: tokenRange)
			 tokens.append(word)
		 }

		 return tokens
	 }

	 // 斷句 by GPT
	 func extractSentences(from text: String) -> [String] {
		 let separators = CharacterSet(charactersIn: "。\n")
		 let sentences = text.components(separatedBy: separators)
			 .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			 .filter { !$0.isEmpty }
		 return sentences
	 }

	
	
	//MARK: - tableView
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return indexes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCellOneMovie
		// 设置较大的宽度
		cell.bounds = CGRect(x: 0, y: 0, width: 1000, height: cell.bounds.height)
  
//		cell.textView?.text = "(" + indexes[indexPath.row].floor + "樓)\n" + indexes[indexPath.row].text //原始 （還沒加紅色粗體）
		let floorString = "(\(indexes[indexPath.row].floor)樓)\n"
		let combinedString = NSMutableAttributedString(string: floorString)
		combinedString.append(indexes[indexPath.row].text)
		
		cell.textView?.attributedText = combinedString
//		print("\(indexPath.row) : \(String(describing: cell.indexLabel?.text))")
//		cell.imageView?.image = UIImage(named: indexes[indexPath.row])
		return cell
	}
	
	// 選擇到的row會跳訊息
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let alert = UIAlertController(
			title: "Row Selected",
			message: "You select \"\(indexes[indexPath.row])\"",
			preferredStyle: .alert
		)
		let action = UIAlertAction(title: "Yes I did", style: .default, handler: nil)
		
		alert.addAction(action)
		
		present(alert, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
	  return 60
	}
}
