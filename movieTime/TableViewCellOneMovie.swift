//
//  TableViewCellOneMovie.swift
//  movieTime
//
//  Created by mac14 on 2023/6/10.
//

import UIKit

class TableViewCellOneMovie: UITableViewCell {

	@IBOutlet weak var indexLabel: UILabel!
	@IBOutlet weak var textView: UITextView!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
