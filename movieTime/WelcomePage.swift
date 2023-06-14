//
//  WelcomePage.swift
//  movieTime
//
//  Created by mac14 on 2023/6/10.
//

import UIKit
class WelcomePage: UIViewController {

	@IBAction func toTestMovie(_ sender: Any) {
		if let vc = storyboard?.instantiateViewController(withIdentifier: "oneMoviePage") {
			show(vc, sender: self)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
