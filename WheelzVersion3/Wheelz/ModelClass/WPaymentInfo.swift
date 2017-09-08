//
//  WPaymentInfo.swift
//  Fender
//
//  Created by Neha Chhabra on 03/09/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WPaymentInfo: NSObject {
    var payeeId : String = ""
    var payerId : String = ""
    var cardNumber : NSInteger = 0
    var expiryYear : NSInteger = 0
    var secureCode : NSInteger = 0
    var isMain : Bool = false
}
