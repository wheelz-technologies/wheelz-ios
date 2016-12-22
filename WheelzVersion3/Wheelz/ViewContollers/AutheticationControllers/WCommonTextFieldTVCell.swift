//
//  WCommonTextFieldTVCell.swift
//  Wheelz
//
//  Created by Neha Chhabra on 27/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WCommonTextFieldTVCell: UITableViewCell {

    @IBOutlet weak var commonTextField: UITextField!
    @IBOutlet weak var commonButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
