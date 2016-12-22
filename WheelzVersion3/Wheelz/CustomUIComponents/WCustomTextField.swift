//
//  WCustomTextField.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 12/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WCustomTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.keyboardType = UIKeyboardType.ASCIICapable
        self.font = KAppRegularFont
        self.layer.cornerRadius = self.frame.size.height/2
        self.clipsToBounds = true
        self.textAlignment = NSTextAlignment.center
        self.autocorrectionType = UITextAutocorrectionType.no
        self.autocapitalizationType = UITextAutocapitalizationType.none
        
//        let padView =  UIView(frame: CGRectMake(0, 0, 15, self.frame.size.height))
//        self.leftView = padView;
//        self.rightView = padView
//        self.leftViewMode = UITextFieldViewMode.Always
        //self.backgroundColor = UIColor.whiteColor()
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName : KAppPlaceholderColor])
        self.useUnderline()
    }
    
//    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
//        return CGRectOffset(bounds, 15, 0)
//    }
//    
//    override func textRectForBounds(bounds: CGRect) -> CGRect {
//        return CGRectOffset(bounds, 15, 0)
//    }
    
//    override func editingRectForBounds(bounds: CGRect) -> CGRect {
//        return CGRectOffset(bounds, 15, 15)
//    }
    
    func useUnderline() {
        
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        super.drawPlaceholder(in: rect)
        self.textAlignment = NSTextAlignment.center
        //        self.keyboardType = UIKeyboardType.ASCIICapable
        self.autocorrectionType = UITextAutocorrectionType.no
        //        self.autocapitalizationType = UITextAutocapitalizationType.None
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName : KAppPlaceholderColor ,NSFontAttributeName : KAppRegularFont])
        self.font = KAppRegularFont
    }

}
