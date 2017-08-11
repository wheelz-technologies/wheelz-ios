//
//  WUserIdentity.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-10-14.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WUserIdentity: NSObject {
    var userID : String = ""
    var token : String = ""
    var zipCode : String = ""
    var city : String = ""
    var state : String = ""
    var addressLine1 : String = ""
    var birthDay : String = ""
    var birthMonth : String = ""
    var birthYear : String = ""
    var personalIdNumber : String = ""
    var ip : String = ""
    var country : String = ""
    
    class func getUserIdentity(_ dict : AnyObject) -> WUserIdentity {
            
        let userIdentity = WUserIdentity()
        let tempDict = dict as! NSDictionary
        userIdentity.userID = tempDict["userId"] as! String
        userIdentity.token = tempDict["token"] as! String
        userIdentity.zipCode = tempDict["zipCode"] as! String
        userIdentity.city = tempDict["city"] as! String
        userIdentity.state = tempDict["state"] as! String
        userIdentity.addressLine1 = tempDict["addressLine1"] as! String
        userIdentity.birthDay = String(format: "%d", tempDict["birthDay"] as! NSInteger)
        userIdentity.birthMonth = String(format: "%d", tempDict["birthMonth"] as! NSInteger)
        userIdentity.birthYear = String(format: "%d", tempDict["birthYear"] as! NSInteger)
        userIdentity.personalIdNumber = tempDict["personalIdNumber"] as! String
        userIdentity.ip = tempDict["ip"] as! String
        return userIdentity
    }
}
