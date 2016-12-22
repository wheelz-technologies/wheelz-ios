//
//  WPaymentSetupDetails.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-10-14.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WPaymentSetupDetails: NSObject {
    var status : String = ""
    var details : String = ""
    
    class func getPaymentSetupDetails(_ dict : AnyObject) -> WPaymentSetupDetails {
        
        let setupDetails = WPaymentSetupDetails()
        let tempDict = dict as! NSDictionary
        setupDetails.status = tempDict["status"] as! String
        setupDetails.details = tempDict["details"] as? String ?? ""
        return setupDetails
    }
}

