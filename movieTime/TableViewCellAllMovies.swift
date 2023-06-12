//
//  TableViewCellAllMovies.swift
//  movieTime
//
//  Created by mac14 on 2023/6/11.
//

import UIKit

class TableViewCellAllMovies: UITableViewCell {

	@IBOutlet weak var selectImage: UIImageView!
	@IBOutlet weak var selectName: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
