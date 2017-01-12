//
//  WAppUtils.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 12/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import SCLAlertView

public enum AlertStyle: Int {
    case Success, Error, Notice, Warning, Info, Edit, Wait
}

// MARK: - Short Terms
let kAppOrangeColor = RGBA(255, g: 85, b: 40, a: 1)
let kAppLightBlueColor = RGBA(0, g: 191, b: 255, a: 1)
let KAppWhiteColor = UIColor.white
let KAppPlaceholderColor = UIColor.lightGray
let KAppTextColor = UIColor.darkGray
let KAppHeaderFont = UIFont.boldSystemFont(ofSize: 18)
let KAppRegularFont = UIFont.boldSystemFont(ofSize: 18)
//let KAppRegularFont = UIFont(name:"HelveticaNeue", size: 18)!
let kAppDarkGrayColor = RGBA(29, g: 35, b: 34, a: 0.2)

let showLog = true

let kAppDelegate = UIApplication.shared.delegate as! AppDelegate
let KAppUserID = UserDefaults.standard.value(forKey: "wheelzUserID")

let Window_Width = UIScreen.main.bounds.size.width
let Window_Height = UIScreen.main.bounds.size.height

// MARK: - Helper functions
func RGBA(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
}

func kAppFont(_ fontSize:CGFloat) -> UIFont {
    return UIFont(name:"HelveticaNeue-Thin", size: fontSize)!
}

func getRoundRect(_ obj : UIButton){
    obj.layer.cornerRadius = obj.frame.size.height/2
    //obj.layer.borderColor = KAppWhiteColor.cgColor
    //obj.layer.borderWidth = 2.0
    obj.clipsToBounds = true
}

func getRoundImage(_ obj : UIImageView){
    obj.layer.cornerRadius = obj.frame.size.height/2
    //obj.layer.borderColor = UIColor.gray.cgColor
    //obj.layer.borderWidth = 2.0
    obj.clipsToBounds = true
}

func getViewWithTag(_ tag:NSInteger, view:UIView) -> UIView {
    return view.viewWithTag(tag)!
}

// custom log
func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    if (showLog) {
        print("\(function): \(line): \(message)")
    }
}

func presentAlert(_ titleStr : String?,msgStr : String?,controller : AnyObject?){
    DispatchQueue.main.async(execute: {
        let alert = UIAlertController(title: titleStr, message: msgStr, preferredStyle: UIAlertControllerStyle.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil));
        //event handler with closure
        controller!.present(alert, animated: true, completion: nil);
        
    })
}

func presentFancyAlert(_ titleStr : String?, msgStr : String?, type: AlertStyle, controller: AnyObject?){
    DispatchQueue.main.async {
        let alert = SCLAlertView()
        
        switch type {
        case AlertStyle.Notice:
            alert.showTitle(
                titleStr ?? "",
                subTitle: msgStr ?? "",
                duration: 0.0,
                completeText: "OK",
                style: SCLAlertViewStyle.notice,
                colorStyle: 0x40434A,
                colorTextButton: 0xFFFFFF
            )
            break
        case AlertStyle.Error:
            alert.showTitle(
                titleStr ?? "",
                subTitle: msgStr ?? "",
                duration: 0.0,
                completeText: "OK",
                style: SCLAlertViewStyle.error,
                colorStyle: 0xd63131,
                colorTextButton: 0xFFFFFF
            )
            break
        default: // info style
            alert.showTitle(
                titleStr ?? "", // Title
                subTitle: msgStr ?? "", // Message
                duration: 0.0, // Duration to show before closing automatically, default: 0.0
                completeText: "OK", // Optional button value, default: ""
                style: SCLAlertViewStyle.info,
                colorStyle: 0xff5528,
                colorTextButton: 0xFFFFFF
            )
            break
        }
    }
}

func newViewControllerFromMain(name: String) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
}

// Helper function to convert from RGB to UIColor
func UIColorFromRGB(_ rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func animateImageBounce(imageView: UIImageView) {
    let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.2, y: 1.2);
    
    imageView.transform = expandTransform
    UIView.animate(withDuration: 0.4,
                   delay:0.0,
                   usingSpringWithDamping:0.40,
                   initialSpringVelocity:0.2,
                   options: .curveEaseOut,
                   animations: {
                    imageView.transform = expandTransform.inverted()
    }, completion: {
        //Code to run after animating
        (value: Bool) in
        return
    })
}

func resizeImage(imageName: String, width: Double, height: Double) -> UIImage? {
    let pinImage = UIImage(named: imageName)
    let pin: Double = 0.0
    let size = CGSize(width: width, height: height)
    UIGraphicsBeginImageContext(size)
    pinImage!.draw(in: CGRect(x: pin, y: pin, width: width, height: height))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return resizedImage
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class WAppUtils: NSObject {
  class  func leftBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: imageName as String), for: UIControlState())
        button.addTarget(controller, action: #selector(leftBarButtonAction(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    class  func rightBarButton(_ imageName : NSString,controller : UIViewController) -> UIBarButtonItem {
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        button.setImage(UIImage(named: imageName as String), for: UIControlState())
        button.addTarget(controller, action: #selector(rightBarButtonAction(_:)), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        return leftBarButtonItem
    }
    
    @objc   func leftBarButtonAction(_ button : UIButton) {
    
    }
    
    @objc   func rightBarButtonAction(_ button : UIButton) {
        
    }
}
