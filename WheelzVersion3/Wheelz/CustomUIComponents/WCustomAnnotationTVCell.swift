//
//  WCustomAnnotationTVCell.swift
//  Wheelz
//
//  Created by Neha Chhabra on 08/09/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WCustomAnnotationTVCell: UITableViewCell {

    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
