//
//  WAlertTVCell.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-12.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WAlertTVCell: UITableViewCell {
    
    @IBOutlet var alertInfoLabel: UILabel!
    @IBOutlet var alertDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
