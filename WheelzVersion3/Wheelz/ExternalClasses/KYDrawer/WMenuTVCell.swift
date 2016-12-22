//
//  WMenuTVCell.swift
//  Wheelz
//
//  Created by Neha Chhabra on 04/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WMenuTVCell: UITableViewCell {

    @IBOutlet var menuLabel: UILabel!
    @IBOutlet var menuImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
            
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
