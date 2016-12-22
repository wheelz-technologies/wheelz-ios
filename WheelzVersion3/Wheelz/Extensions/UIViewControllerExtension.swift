//
//  UIViewControllerExtension.swift
//  Template
//
//  Created by Raj Kumar Sharma on 26/10/15.
//  Copyright © 2015 Mobiloitte. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public func moveUIComponentWithValue(_ value:CGFloat, forLayoutConstraint:NSLayoutConstraint, forDuration:TimeInterval) {
        UIView.beginAnimations("MoveView", context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(forDuration)
        forLayoutConstraint.constant = value
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    public func animateUIComponentWithValue(_ value:CGFloat, forLayoutConstraint:NSLayoutConstraint, forDuration:TimeInterval) {
        
        forLayoutConstraint.constant = value
        
        UIView.animate(withDuration: forDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
            
            }) { (Bool) -> Void in
                // do anything on completion
        }
    }
    
    func backBarBackButton(_ imageName : NSString) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControlState())
        button.addTarget(self, action: #selector(backBarBackButtonAction(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    func backBarBackButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
