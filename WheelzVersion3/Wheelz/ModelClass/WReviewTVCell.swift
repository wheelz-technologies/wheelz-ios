//
//  WReviewTVCell.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2017-02-17.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WReviewTVCell: BWSwipeRevealCell {
    
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

