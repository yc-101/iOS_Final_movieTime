//
//  TableViewControllerAllMovies.swift
//  movieTime
//
//  Created by mac14 on 2023/6/11.
//

import UIKit
import Alamofire
import Kanna
import FakeUserAgent
import Kingfisher
import NaturalLanguage

class TableViewControllerAllMovies: UITableViewController {
	
	struct movie_struct {
		var name: String = ""
		var imageName: String = ""
		var imageUrl: String = ""
		var backUrl: String = ""
		var tags: [String: Int] = [:]
	}
	
	var movies:[movie_struct] = Array()
	lazy var filteredMovies = movies
	var selectedMovie = movie_struct()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let searchController = UISearchController()
		navigationItem.searchController = searchController
		searchController.searchResultsUpdater = self
		navigationItem.hidesSearchBarWhenScrolling = false
		navigationItem.title = "Select a movie🎬"
		buildAllMovies()
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
	
	func buildAllMovies() {
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
		let url = "https://forum.gamer.com.tw/B.php?bsn=60200&qt=2"
		AF.request(url, headers: headers).responseString { response in

			switch response.result {
			case .success(let html):
				// 成功获取到HTML数据
				// 使用Kanna解析HTML
				print("load successful!")
				var doc = try? Kanna.HTML(html: html, encoding: String.Encoding.utf8)
				
				// 找每一樓（不包含留言）的文章內容
				if let articles = doc?.xpath("//td[contains(@class, 'b-list__main')]"){
					
					for article in articles {
						// 尋找title
						if let title = article.at_xpath(".//p[contains(@class, 'b-list__main__title')]") {
							let titleText = title.text
							
							if(titleText!.contains("討論集中串")) {
								var newMovie = movie_struct()
								//擷取titleText
								if let range = titleText!.range(of: "【討論】") {
									let startIndex = range.upperBound
									let endIndex = titleText!.index(of: " ") ?? titleText!.endIndex
									let extractedString = String(titleText![startIndex..<endIndex])
									newMovie.name = extractedString
								}
								
								// 尋找該url
								  if let a_url = article.at_xpath(".//a/@href") {
									  let hrefValue = a_url.text
									  let suffix = hrefValue!.suffix(from: hrefValue!.index(hrefValue!.startIndex, offsetBy: 6))
									  newMovie.backUrl = String("&" + suffix)
									  
									  // MARK: - 計算詞頻(tag) (FAIL)
									  let randomDelay = Double(arc4random_uniform(3) + 1) // Random delay between 1 and 3 seconds
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
										  let url = "https://forum.gamer.com.tw/C.php?page=1\(newMovie.backUrl)"
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
													  // 找每一樓（不包含留言）的文章內容
													  let articles = doc?.xpath("//div[contains(@class, 'c-section__main c-post ')]")
											  //		print(articles)
													  for article in articles! {
														   // 提取 <article> 标签的文本内容
														   if let articleText = article.xpath(".//article[@class='c-article FM-P2']").first {
//											  	 				print("Article text:", articleText.text ?? "")
															   let ws = ViewControllerOneMovie().extractSentences(from: articleText.text!)
															   for w in ws {
																   // Create an NLTagger instance
																   let tagger = NLTagger(tagSchemes: [.lexicalClass])

																   // Set the text
																   tagger.string = w

																   tagger.enumerateTags(in: w.startIndex..<w.endIndex, unit: .word, scheme: .lexicalClass, options: []) { tag, tokenRange in
																	   if let tag = tag {
																		   let word = String(w[tokenRange])
																		   let lexicalClass = tag.rawValue
																		   if (word != "，") && (word != "。") && (word != "但") {
																			   newMovie.tags[word, default: 0] += 1
																		   }
																	   }
																	   return true
																   }
															   }
														   }
													   }
												  }
											  case .failure(let error):
												  print("ERROR: AF.request load failed, returning...")
												  print(error)
											  }
										  }
									  }
									  print("tags: ",newMovie.tags)
								 }
								//尋找圖片
								if let thumbnailElement = article.at_xpath(".//div[contains(@class, 'b-list__img')]/@data-thumbnail") {
									let thumbnailURL = thumbnailElement.text
									newMovie.imageUrl = thumbnailURL!
								}
								self.movies.append(newMovie)
								self.filteredMovies = self.movies
								self.tableView.reloadData()
							}
						}
					}
				}
				
			case .failure(let error):
				// 处理错误
//				 check = false
				print("ERROR : AF.request load failed, returning...")
				print(error)
			}
		}
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return filteredMovies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellAllMovies
		cell.selectName.text = filteredMovies[indexPath.row].name
		let url = URL(string: filteredMovies[indexPath.row].imageUrl)
		cell.selectImage.kf.setImage(with: url)
        return cell
    }
    
	// 選擇到的row會跑去顯示標籤搜尋結果
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedMovie = filteredMovies[indexPath.row]
		print("選擇電影：\(selectedMovie.name), url: \(selectedMovie.backUrl)")
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		let controller = segue.destination as? ViewControllerSelectTag
		
		if let row = tableView.indexPathForSelectedRow?.row {
			controller?.backUrl = filteredMovies[row].backUrl // "&bsn=60200&snA=40082&tnum=58"
			controller?.navigationItem.title = filteredMovies[row].name
			
			
//			controller?.tagDic = self.movies[row].tags
		}
    }
	
	func tokenize(original: [String : Int], sentence: String) -> [Dictionary<String, Int>.Element] {
		// Create an NLTagger instance
		let tagger = NLTagger(tagSchemes: [.lexicalClass])

		// Set the text
		tagger.string = sentence

		// Calculate word frequency
		var wordFrequency: [String: Int] = original

		tagger.enumerateTags(in: sentence.startIndex..<sentence.endIndex, unit: .word, scheme: .lexicalClass, options: []) { tag, tokenRange in
			if let tag = tag {
				let word = String(sentence[tokenRange])
				let lexicalClass = tag.rawValue
				if (word != "，") && (word != "。") && (word != "但") {
					wordFrequency[word, default: 0] += 1
				}
			}
			return true
		}
		let sortedWordFrequency = wordFrequency.sorted { $0.value > $1.value }
		// Print word frequency results
//		for (word, frequency) in wordFrequency {
//			print("\(word): \(frequency)")
//		}
		return sortedWordFrequency
	}
}

extension TableViewControllerAllMovies: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		if let searchText = searchController.searchBar.text,
		!searchText.isEmpty {
			filteredMovies = movies.filter { movie in
				return movie.name.localizedStandardContains(searchText)
			}
			// Update your table view's data source with the filtered tags
			// For example, if your table view has a data source array called 'dataSource', you can do:
//				tags = t
		} else {
			// Set the table view's data source to the original array of tags
			// For example, if your table view has a data source array called 'dataSource', you can do:
			filteredMovies = movies
		}
		
		tableView.reloadData()
	}
}
