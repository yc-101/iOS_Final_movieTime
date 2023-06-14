//
//  ViewControllerSelectTag.swift
//  movieTime
//
//  Created by mac14 on 2023/6/11.
//

import UIKit

class ViewControllerSelectTag: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var backUrl = String()
	var t = ["劇情", "角色", "畫面"]
	lazy var tags = t
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let searchController = UISearchController()
		navigationItem.searchController = searchController
		searchController.searchResultsUpdater = self
		navigationItem.hidesSearchBarWhenScrolling = false
		
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
	}
	
}

extension ViewControllerSelectTag: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		
		if let searchText = searchController.searchBar.text,
		!searchText.isEmpty {
			tags = t.filter { tag in
				tag.localizedStandardContains(searchText)
			}
			// Update your table view's data source with the filtered tags
			// For example, if your table view has a data source array called 'dataSource', you can do:
//				tags = t
		} else {
			// Set the table view's data source to the original array of tags
			// For example, if your table view has a data source array called 'dataSource', you can do:
			tags = t
		}
		
		tableView.reloadData()
	}
}
