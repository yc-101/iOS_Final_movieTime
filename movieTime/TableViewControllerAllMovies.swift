//
//  TableViewControllerAllMovies.swift
//  movieTime
//
//  Created by mac14 on 2023/6/11.
//

import UIKit

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
	}
	
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
