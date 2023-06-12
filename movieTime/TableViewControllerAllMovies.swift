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

class TableViewControllerAllMovies: UITableViewController {
	
	struct movie_struct {
		var name: String = ""
		var imageName: String = ""
		var backUrl: String = ""
	}
	
	var movies:[movie_struct] = Array()
	var selectedMovie = movie_struct()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.title = "Select a movie🎬"
		buildAllMovies()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
	
	func buildAllMovies() {
		movies.append(movie_struct(name: "玩命關頭X", imageName: "0", backUrl: "&bsn=60200&snA=40082&tnum=58"))
		movies.append(movie_struct(name: "變形金剛：萬獸崛起", imageName: "1", backUrl: "&bsn=60200&snA=40139&tnum=48"))
		movies.append(movie_struct(name: "小美人魚", imageName: "2", backUrl: "&bsn=60200&snA=40119&tnum=45"))
		
	}
	/*
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
	 }
	*/
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return movies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCellAllMovies
		cell.selectName.text = movies[indexPath.row].name
		cell.selectImage.image = UIImage(named: movies[indexPath.row].imageName)
        return cell
    }
    
	// 選擇到的row會跑去顯示標籤搜尋結果
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedMovie = movies[indexPath.row]
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
			controller?.backUrl = movies[row].backUrl // "&bsn=60200&snA=40082&tnum=58"
			controller?.navigationItem.title = movies[row].name
		}
    }
	

}
