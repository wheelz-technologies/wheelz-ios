//
//  WPaymentsTVCell.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WPaymentTVCell: BWSwipeRevealCell {
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var cardInfoLabel: UILabel!
    @IBOutlet weak var cardTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
