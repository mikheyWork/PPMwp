//
//  CepiaTVCell.swift
//  ppmiPhone2
//
//  Created by softevol on 10/22/18.
//  Copyright © 2018 softevol. All rights reserved.
//

import UIKit

class CepiaTVCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var resultsLbl: UILabel!
    
    var text2 = ""
    var id = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
