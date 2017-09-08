//
//  WPromoCode.swift
//  Fender
//
//  Created by Logan Wolfe on 2017-09-02.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WPromoCode: NSObject {
    
    var promoCodeId : String = ""
    var userId : String = ""
    var code : String = ""
    var discount : NSInteger = 0
    
    class func getPromoCode(_ dict : NSMutableDictionary) -> WPromoCode {
        let promoCode = WPromoCode()
        
        promoCode.promoCodeId = dict["lessonId"] as! String
        promoCode.userId = dict["userId"] as! String
        promoCode.code = dict["code"] as! String
        promoCode.discount = dict["discount"] as! NSInteger
        
        return promoCode
    }
}

