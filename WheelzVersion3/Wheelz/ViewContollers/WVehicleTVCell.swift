//
//  WVehicleTVCell.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WVehicleTVCell: BWSwipeRevealCell {
    
    @IBOutlet weak var modelYearLabel: UILabel!
    @IBOutlet weak var vinLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
