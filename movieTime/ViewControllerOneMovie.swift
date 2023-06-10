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

class ViewControllerOneMovie: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet weak var indexTableView: UITableView!
	
	struct data_struct {
//		var date: String = ""
		var floor: String = ""
		var text: String = ""
	}
	
	var indexes:[data_struct] = Array()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		load_data()
    }
	
	
	
	func load_data() {
		var page = 1
		print("loading...")
		while(true) {
			let url = "https://forum.gamer.com.tw/C.php?page=\(page)&bsn=60200&snA=40082&tnum=58"
			AF.request(url).responseString { response in
				switch response.result {
				case .success(let html):
					// 成功获取到HTML数据
					// 使用Kanna解析HTML
					print("load successful!")
					self.parsehtml(html)
				case .failure(let error):
					// 处理错误
					print("load failed, returning...")
					print(error)
					return;
				}
			}
			page += 1
		}
	}
	
	func parsehtml(_ html1:String)  {
		let doc = try? Kanna.HTML(html: html1, encoding: String.Encoding.utf8)
		var s = data_struct()
		
		// 找每一樓（不包含留言）的文章內容
		let articles = doc!.xpath("//div[contains(@class, 'c-section__main c-post ')]")
		for article in articles {
			
//			print("article: \(article.text)")
			
			// 提取 data-floor 属性的值
			let dataFloor = article.xpath(".//div[@class='c-post__header__author']//a[@class='floor tippy-gpbp']").first!["data-floor"]!
			s.floor = dataFloor
//			print("data-floor:", dataFloor)
			
			// 提取 <article> 标签的文本内容
			if let articleText = article.xpath(".//article[@class='c-article FM-P2']").first {
//				print("Article text:", articleText.text ?? "")
				let ws = extractSentences(from: articleText.text!)
				for w in ws {
					if(w.contains("劇情")){
						print("(\(dataFloor))劇情句: \(w)")
						s.text = w
						
						indexes.append(s)
					}
				}
//				print("Article Text: \(text)")
			}
		}
		indexTableView.reloadData()

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
