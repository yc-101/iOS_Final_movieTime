//
//  ViewControllerSelectTag.swift
//  movieTime
//
//  Created by mac14 on 2023/6/11.
//

import UIKit

class ViewControllerSelectTag: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var backUrl = String()
	var tags: [String] = ["劇情", "角色", "畫面"]
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let str = TableViewControllerAllMovies().selectedMovie.name
		print(TableViewControllerAllMovies().selectedMovie.name)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "oneMovieSegue" {
			let controller = segue.destination as? ViewControllerOneMovie
			//MARK: - 記得做搜尋功能確認（是否按下？）
			if let row = tableView.indexPathForSelectedRow?.row {
				controller?.backUrl = backUrl
				controller?.tag = tags[row]
			}
		}
    }
    

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath)
		// 设置较大的宽度
		cell.bounds = CGRect(x: 0, y: 0, width: 1000, height: cell.bounds.height)
  
		cell.textLabel?.text = tags[indexPath.row]
		
//		print("\(indexPath.row) : \(String(describing: cell.indexLabel?.text))")
//		cell.imageView?.image = UIImage(named: indexes[indexPath.row])
		return cell
	}
	
	// 選擇到的row會跳訊息
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("row = ", indexPath.row)
//		if let vc = storyboard?.instantiateViewController(withIdentifier: "oneMoviePage") {
//			show(vc, sender: self)
//		}
//		if let vc = storyboard?.instantiateViewController(withIdentifier: "oneMoviePage") {
//			self.navigationController?.pushViewController(vc, animated: true)
//		}
//		if segue.
	}
	
}
