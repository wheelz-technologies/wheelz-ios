//
//  WUserReview.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2017-02-17.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WUserReview: NSObject {
    var userID : String = ""
    var text : String = ""
    var rating : NSInteger = 0
    
    class func getUserReview(_ dict : AnyObject) -> WUserReview {
        
        let userReview = WUserReview()
        let tempDict = dict as! NSDictionary
        userReview.userID = tempDict["userId"] as! String
        userReview.text = tempDict["text"] as! String
        userReview.rating = tempDict["rating"] as! NSInteger
        return userReview
    }
    
    class func getUserReviews(_ arr : NSMutableArray) -> NSMutableArray {
        
        let tempArray = NSMutableArray()
        
        for case let tempDict as NSDictionary in arr {
            let userReview = WUserReview()
            userReview.userID = tempDict["userId"] as! String
            userReview.text = tempDict["text"] as! String
            userReview.rating = tempDict["rating"] as! NSInteger
            tempArray.add(userReview)
        }
        
        return tempArray
    }
}
