//
//  ProductTypesTVCell.swift
//  WP.m.1
//
//  Created by softevol on 9/13/18.
//  Copyright © 2018 softevol. All rights reserved.
//

import UIKit

class ProductTypesTVCell: UITableViewCell {

    
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var resaultLbl: UILabel!

    var id: Int64 = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
