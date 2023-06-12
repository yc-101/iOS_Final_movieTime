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
	
	@IBOutlet weak var indexTableView: UITableView!
	var backUrl = String()
	var tag = String()
	var indexes:[data_struct] = Array()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("(url, tag) = (\(String(backUrl)), \(tag))")
		let queue = DispatchQueue.global(qos: .default)
		queue.async {
			
			DispatchQueue.main.async {
				let arr: [data_struct] = load_data(backUrl: self.backUrl, tag: self.tag)
				print(arr.count)
				if (arr.count > 0 && !arr[0].text.contains("ERROR")) {
					
					self.indexes.append(contentsOf: arr)
					self.indexTableView.reloadData()
				}
//				else {
//					let alertController = UIAlertController(title: "Error", message: "巴哈維修中:(", preferredStyle: .alert)
//					alertController.addAction(UIAlertAction(title: "OK", style: .default) {_ in
//						if let vc = self.storyboard?.instantiateViewController(withIdentifier: "welcomePage") {
//							self.show(vc, sender: self)
//						}
//					})
//					self.present(alertController, animated: true)
//				}
			}
		}
    }
	
	//MARK: - html parser
	
	let PAGE_LIMIT = 1

	 struct data_struct {
	 //		var date: String = ""
		 var floor: String = ""
		 var text: String = ""
	 }

	 func load_data(backUrl: String, tag: String) -> [data_struct] {
		 var page = 1
		 var check = true
		 var ssReturn: [data_struct] = Array()
		 print("loading...")
		 
			 
		 while(page <= PAGE_LIMIT) {
			 
			 let randomDelay = Double(arc4random_uniform(3) + 1) // 1到3秒的随机延迟
			 DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
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
				 let url = "https://forum.gamer.com.tw/C.php?page=\(page)\(backUrl)"
				 AF.request(url, headers: headers).responseString { response in
					 
					 switch response.result {
					 case .success(let html):
						 // 成功获取到HTML数据
						 // 使用Kanna解析HTML
						 print("load successful!")
	 //					print(html)
						 let doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8)
						 if(doc?.xpath("/html/body/div").first?.className == "maintain") {
							 check = false
							 ssReturn.append(data_struct(floor: "", text: "ERROR : 伺服器錯誤"))
							 break
						 }
						 
						 else{
							 let arr = parsehtml(doc: doc!, tag: tag)
							 ssReturn.append(contentsOf: arr)
						 }
					 case .failure(let error):
						 // 处理错误
						 check = false
						 ssReturn.append(data_struct(floor: "", text: "ERROR : load failed"))
						 print("load failed, returning...")
						 print(error)
					 }
				 }
				 print("processing, please wait...")
			 }
			 
			 if check == false {
				 print("error detected, return ssReturn.count = ", ssReturn.count)
				 return ssReturn
			 }
			 page += 1
		 }
		 print("ssReturn: ", ssReturn)
		 return ssReturn
	 }

	 func parsehtml(doc: HTMLDocument, tag: String) -> [data_struct]  {
		 var ssReturn: [data_struct] = Array()
		 var s = data_struct()
//		 print(doc.title)
		 // 找每一樓（不包含留言）的文章內容
		 let articles = doc.xpath("//div[contains(@class, 'c-section__main c-post ')]")
		 print(articles)
		 print("尋找的關鍵字：\(tag)")
		 for article in articles {
			 
	 //		print("article: \(article.text)")
			 
			 // 提取 data-floor 属性的值
			 let dataFloor = article.xpath(".//div[@class='c-post__header__author']//a[@class='floor tippy-gpbp']").first!["data-floor"]!
			 s.floor = dataFloor
	 //			print("data-floor:", dataFloor)
			 
			 // 提取 <article> 标签的文本内容
			 if let articleText = article.xpath(".//article[@class='c-article FM-P2']").first {
	 //				print("Article text:", articleText.text ?? "")
				 let ws = extractSentences(from: articleText.text!)
				 for w in ws {
					 if(w.contains(tag)){ // eg. "劇情"
						 print("(\(dataFloor)) : \(w)")
						 s.text = w
						 
						 ssReturn.append(s)
					 }
				 }
	 //				print("Article Text: \(text)")
			 }
		 }
		 //MARK: - 要記得reload data！
		 return ssReturn;
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
  
		cell.textView?.text = String(indexes[indexPath.row].floor + "F\n"  +   indexes[indexPath.row].text)
		
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
