//
//  GeneralExtensions.swift
//  Template
//
//  Created by Raj Kumar Sharma on 04/04/16.
//  Copyright © 2016 Mobiloitte. All rights reserved.
//

import UIKit

// MARK:- Array Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Array {
    func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
// MARK :- Pan Gesture Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIPanGestureRecognizer {
    
    func isLeft(_ theViewYouArePassing: UIView) -> Bool {
        let velocity : CGPoint = self.velocity(in: theViewYouArePassing)
        if velocity.x > 0 {
            print("Gesture went right")
            return false
        } else {
            print("Gesture went left")
            return true
        }
    }
}

// MARK:- Dictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Dictionary {
    mutating func unionInPlace(
        _ dictionary: Dictionary<Key, Value>) {
            for (key, value) in dictionary {
                self[key] = value
            }
    }
    
    mutating func unionInPlace<S: Sequence>(_ sequence: S) where S.Iterator.Element == (Key,Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
    
    func validatedValue(_ key: Key, expected: AnyObject) -> AnyObject {
        
        // checking if in case object is nil

        if let object = self[key] as? AnyObject{
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if (object.isKind(of: expected.classForCoder) == false) {
                //logInfo("case // checking if object is of desired class....not")
                
                return expected
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    //logInfo("null string")
                    return "" as AnyObject
                }
            }
            
            return object
        }
        else {

            if expected is String || expected as! String == "" {
             return "" as AnyObject
            }
            
            return expected
        }
    }
   
}

// MARK:- NSDictionary Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension NSDictionary {
    
    func objectForKeyNotNull(_ key:AnyObject, expected:AnyObject?) -> AnyObject {
        
        // checking if in case object is nil
        if let object = self.object(forKey: key) {
            
            // added helper to check if in case we are getting number from server but we want a string from it
            if object is NSNumber && expected is String {
                
                //logInfo("case we are getting number from server but we want a string from it")
                
                return "\(object)" as AnyObject
            }
                
                // checking if object is of desired class
            else if ((object as AnyObject).isKind(of: (expected?.classForCoder)!) == false) {
                
                //logInfo("case // checking if object is of desired class....not")
                
                return expected!
            }
                
                // checking if in case object if of string type and we are getting nil inside quotes
            else if object is String {
                if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                    
                    //logInfo("null string")
                    
                    return "" as AnyObject
                }
            }
            return object as AnyObject
            
        } else {
            
            if expected is String || expected as! String == "" {
                return "" as AnyObject
            }
            
            return expected!
        }
    }
    
    func objectForKeyNotNull(_ key:AnyObject) -> AnyObject {
        
        let object = self.object(forKey: key)
        
        if object is NSNull {
            return "" as AnyObject
        }
        
        if (object == nil) {
            return "" as AnyObject
        }
        
        if object is NSString {
            if ((object as! String == "null") || (object as! String == "<null>") || (object as! String == "(null)")) {
                return "" as AnyObject
            }
        }
        return object! as AnyObject
    }
    
    func objectForKeyNotNullExpectedObj(_ key:AnyObject, expectedObj:AnyObject) -> AnyObject {
        
        let object = self.object(forKey: key)
        
        if object is NSNull {
            return expectedObj
        }
        
        if (object == nil) {
            return expectedObj
        }
        
        if (((object as AnyObject).isKind(of: expectedObj.classForCoder)) == nil) {
            return expectedObj
        }
        
        return object! as AnyObject
    }
}

// MARK:- UIView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            
            self.layer.cornerRadius = newValue
            self.clipsToBounds = true
        }
    }
    
    func shadow(_ color:UIColor) {
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    func setNormalRoundedShadow(_ color:UIColor) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.3, height: 0.3)
    }
    
    func setBorder(_ color:UIColor, borderWidth:CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.clipsToBounds = true
    }
    
    func vibrate() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.02
        animation.repeatCount = 2
        animation.speed = 0.5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 2.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 2.0, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
    func shake() {
        self.transform = CGAffineTransform(translationX: 5, y: 5)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    func setTapperTriangleShape(_ color:UIColor) {
        // Build a triangular path
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0,y: 0))
        path.addLine(to: CGPoint(x: 40,y: 40))
        path.addLine(to: CGPoint(x: 0,y: 100))
        path.addLine(to: CGPoint(x: 0,y: 0))
        
        // Create a CAShapeLayer with this triangular path
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        // Mask the view's layer with this shape
        self.layer.mask = mask
        
        self.backgroundColor = color
        
        // Transform the view for tapper shape
        self.transform = CGAffineTransform(rotationAngle: CGFloat(270) * CGFloat(M_PI_2) / 180.0)
    }
}

// MARK:- UISlider Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UISlider {
    @IBInspectable var thumbImage: UIImage {
        get {
            return self.thumbImage(for: UIControlState())!
        }
        set {
            self.setThumbImage(thumbImage, for: UIControlState())
        }
    }
}

// MARK:- NSURL Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension URL {
    
    func isValid() -> Bool {
        if UIApplication.shared.canOpenURL(self) == true {
            return true
        } else {
            return false
        }
    }
}

// MARK:- NSDate Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Date {
    
    func timestamp() -> String {
        return "\(self.timeIntervalSince1970)"
    }
    
    func dateString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return dateFormatter.string(from: self)
    }
    func dateStringFromDate(_ format:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func timeStringFromDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: self)
    }
    
    func yearsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date:Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date:Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

// Usage

/*
 let date1 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date2 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 8, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let years = date2.yearsFrom(date1)     // 0
 let months = date2.monthsFrom(date1)   // 9
 let weeks = date2.weeksFrom(date1)     // 39
 let days = date2.daysFrom(date1)       // 273
 let hours = date2.hoursFrom(date1)     // 6,553
 let minutes = date2.minutesFrom(date1) // 393,180
 let seconds = date2.secondsFrom(date1) // 23,590,800
 
 let timeOffset = date2.offsetFrom(date1) // "9M"
 
 let date3 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date4 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let timeOffset2 = date4.offsetFrom(date3) // "1y"
 
 let timeOffset3 = NSDate().offsetFrom(date3) // "54m"
 */

// MARK:- UIViewController Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIViewController {
    
    func backViewController() -> UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for count in 0...stack.count - 1 {
                if(stack[count] == self) {
                    logInfo("viewController     \(stack[count-1])")

                    return stack[count-1]
                }
            }
        }
        return nil
    }
    /*: UNUserNotificationCenterDelegate*/
    /*@available(iOS 10.0, *)
     public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
     completionHandler( [.alert, .badge, .sound])
     }
     
     public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
     
     }*/
}

// MARK:- Int/Float/Double Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension Int {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)d" as NSString, self) as String
    }
}

extension Double {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension Float {
    func format(_ f: String) -> String {
        return NSString(format: "%\(f)f" as NSString, self) as String
    }
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0", "":
            return false
        default:
            return nil
        }
    }
}

/*extension Character {
    func isEmoji() -> Bool {
        return Character(UnicodeScalar(0x1d000)) <= self && self <= Character(UnicodeScalar(0x1f77f))
            || Character(UnicodeScalar(0x2100)) <= self && self <= Character(UnicodeScalar(0x26ff))
    }
}*/

//extension String {
//    func stringByRemovingEmoji() -> String {
//        return String(filter(self, {c in !c.isEmoji()}))
//    }
//}

// MARK:- UIImageView Extensions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

extension UIImageView {
    
    /*>>>>>>>>>>>>>>>>>>>>>>>>>>>> Changing icon color according to theme <<<<<<<<<<<<<<<<<<<<<<<<*/
    func setColor(_ color:UIColor) {
        
        if let image = self.image {
            var s = image.size // CGSize
            s.height *= image.scale
            s.width *= image.scale
            
            UIGraphicsBeginImageContext(s)
            
            var contextRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: s)
            
            // Retrieve source image and begin image context
            let itemImageSize = s //CGSize
            
            let xVal = (contextRect.size.width - itemImageSize.width)/2
            let yVal = (contextRect.size.height - itemImageSize.height)
            
            //let itemImagePosition = CGPoint(x: ceilf(xFloatVal), y: ceilf(yVal)) //CGPoint
            
            let itemImagePosition = CGPoint(x: xVal, y: yVal) //CGPoint
            
            UIGraphicsBeginImageContext(contextRect.size)
            
            let c = UIGraphicsGetCurrentContext() //CGContextRef
            
            // Setup shadow
            // Setup transparency layer and clip to mask
            c?.beginTransparencyLayer(auxiliaryInfo: nil)
            c?.scaleBy(x: 1.0, y: -1.0)
            
            //CGContextRotateCTM(c, M_1_PI)
            
            c?.clip(to: CGRect(x: itemImagePosition.x, y: -itemImagePosition.y, width: itemImageSize.width, height: -itemImageSize.height), mask: image.cgImage!)
            
            // Fill and end the transparency layer
            let colorSpace = color.cgColor.colorSpace //CGColorSpaceRef
            let model = colorSpace?.model //CGColorSpaceModel
            
            let colors = color.cgColor.components
            
            if (model == .monochrome) {
                c?.setFillColor(red: (colors?[0])!, green: (colors?[0])!, blue: (colors?[0])!, alpha: (colors?[1])!)
            } else {
                c?.setFillColor(red: (colors?[0])!, green: (colors?[1])!, blue: (colors?[2])!, alpha: (colors?[3])!)
            }
            
            contextRect.size.height = -contextRect.size.height
            contextRect.size.height -= 15
            c?.fill(contextRect)
            c?.endTransparencyLayer()
            
            let img = UIGraphicsGetImageFromCurrentImageContext() //UIImage
            
            let img2 = UIImage(cgImage: (img?.cgImage!)!, scale: image.scale, orientation: image.imageOrientation)
            
            UIGraphicsEndImageContext()
            
            self.image = img2
            
        } else {
            print("Unable to chage color of image. Image not found")
        }
    }
}
