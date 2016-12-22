//
//  WCustomButton.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 12/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WCustomButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.titleLabel?.font = KAppRegularFont
        self.backgroundColor = kAppOrangeColor
        self.setTitleColor(KAppWhiteColor, for: UIControlState())
        //self.layer.cornerRadius = self.frame.size.height/2
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.isExclusiveTouch = true
        self.layer.borderColor = kAppOrangeColor.cgColor;
        self.layer.borderWidth = 2
    }
}
