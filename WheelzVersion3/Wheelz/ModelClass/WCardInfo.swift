//
//  Card.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-09-27.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WCardInfo: NSObject {
    
    var CustomerId : String = ""
    var id : String = ""
    var brand : String = ""
    var last4 : String = ""
    
    class func getCardInfo(_ arr : NSMutableArray) -> NSMutableArray {
        let tempArray = NSMutableArray()
        for case let tempDict as NSDictionary in arr {
            let cardInfo = WCardInfo()
            cardInfo.CustomerId = tempDict["CustomerId"] as! String
            cardInfo.id = (tempDict["id"] as! String)
            cardInfo.brand = tempDict["brand"] as! String
            cardInfo.last4 = tempDict["last4"] as! String
            tempArray.add(cardInfo)
        }
        return tempArray
    }
    
    class func getCardDetail(_ response : NSMutableDictionary) -> NSMutableArray {
        let cardArray = NSMutableArray()
        for case let tempDict as NSDictionary in  response["makes"] as! NSMutableArray{
                let cardInfo = WCardInfo()
                cardInfo.last4 = tempDict["last4"] as! String
                cardArray.add(cardInfo)
            }
            return cardArray
    }
}
