//
//  WUserInfo.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 12/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WUserInfo: NSObject {
    var userID : String = ""
    var userName : String = ""
    var userEmail : String = ""
    var userPhone : String = ""
    var userFName : String = ""
    var userLName : String = ""
    var userPassword : String = ""
    var userPasswordHash : String = ""
    var userImage : String = ""
    var userType : String = ""
    var userCity : String = ""
    var userCountry : String = ""
    var userLocation : String = ""
    var userLicenseNumber : String = ""
    var userDetail : String = ""
    var userLicenseLevel : String = ""
    var userInformation : String = ""
    var lessonCount : String = ""
    var isRegisteredDriver : Bool = false
    var isDriver: Bool = false
    var userImageFileName: String = ""
    var userRating: Double = 0.0
    var deviceToken: String = ""
    
    class func getUserInfo(_ dict : AnyObject) -> WUserInfo {
        
        let userInfo = WUserInfo()
        let tempDict = dict as! NSDictionary
        userInfo.userID = tempDict["userId"] as! String
        userInfo.userName = (tempDict["firstName"] as! String) + " " + (tempDict["lastName"] as? String ?? "")
         userInfo.userFName = tempDict["firstName"] as! String
         userInfo.userLName = tempDict["lastName"] as? String ?? ""
        userInfo.userPassword = tempDict["password"] as! String
        userInfo.userImage = String(format: "https://soireedev.azurewebsites.net/images/%@", tempDict["pic"] as? String ?? "")
        userInfo.userImageFileName = tempDict["pic"] as? String ?? ""
        userInfo.userEmail = tempDict["userName"] as! String
        userInfo.userCity = tempDict["city"] as? String ?? ""
        userInfo.userCountry = tempDict["country"] as? String ?? ""
        userInfo.userLicenseNumber = tempDict["licenseNumber"] as! String
        userInfo.userLicenseLevel = tempDict["licenseLevel"] as! String
        userInfo.lessonCount = String(format: "%d", tempDict["lessonCount"] as! NSInteger)
        userInfo.userRating = tempDict["rating"] as! Double
        userInfo.userPhone = String(format: "%@", tempDict["phoneNumber"] as? String ?? "")
        userInfo.isRegisteredDriver = tempDict["isInstructor"] as! Bool
        userInfo.isDriver = tempDict["isDriver"] as! Bool
        userInfo.userLocation = String(format: "%@,%@", userInfo.userCity  ,userInfo.userCountry)
        userInfo.userCountry = tempDict["deviceToken"] as? String ?? ""
        return userInfo
    }
}
