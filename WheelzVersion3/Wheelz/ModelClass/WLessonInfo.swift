//
//  WLessonInfo.swift
//  Fender
//
//  Created by Probir Chakraborty on 07/08/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WLessonInfo: NSObject {

    var lessonID : String = ""
    var studentID : String = ""
    var driverID : String = ""
    var promoCodeID : String = ""
    var lessonHolderName : String = ""
    var lessonHolderPic : String = ""
    var pic : String = ""
    var lessonStatus : String = ""
    var locLat : Double = 0.0
    var locLon : Double = 0.0
    var driverStarted : Bool = false
    var studentStarted : Bool = false
    var finished : Bool = false
    var paid : Bool = false
    var lessonDateTime : Date = Date()
    var lessonDate : String = ""
    var lessonTimestamp : Double = 0.0
    var lessonStartTimestamp : Double = 0.0
    var lessonDuration : Double = 0.0
    var isInstructorRequired : Bool = false
    var lessonAmount : Double = 0.0
    var lessonTag : NSInteger = 0
    var studentRated : Bool = false
    var driverRated : Bool = false
    var lessonType : NSInteger = 0
    var isConfirmed : Bool = false
    var lessonHolderLicenseLevel : String = ""
    
    class func getLessonHistoryInfo(_ arr : NSMutableArray) -> NSMutableArray {
        let tempArray = NSMutableArray()
        for case let tempDict as NSDictionary in arr {
            let historyLessonInfo = WLessonInfo()
            
            historyLessonInfo.lessonID = (tempDict["lessonId"] as! String)
            historyLessonInfo.lessonHolderName = tempDict["firstName"] as? String ?? ""
            historyLessonInfo.pic = tempDict["pic"] as? String ?? ""
            historyLessonInfo.lessonHolderPic =  String(format: "\(apiUrl)/images/%@", tempDict["pic"] as? String ?? "")
            historyLessonInfo.lessonStatus = tempDict["status"] as? String ?? ""
            historyLessonInfo.lessonDate = tempDict["dateTime"] as? String ?? ""
//            historyLessonInfo.locLat = tempDict["locLatitude"] as! Double
//            historyLessonInfo.locLon = tempDict["locLongitude"] as! Double
            historyLessonInfo.lessonAmount = tempDict["amount"] as! Double
//            historyLessonInfo.lessonDuration = tempDict["duration"] as! Double
//            historyLessonInfo.isInstructorRequired = tempDict["instructorRequired"] as! Bool
            historyLessonInfo.lessonTimestamp = tempDict["utcDateTime"] as! Double
            historyLessonInfo.isConfirmed = tempDict["confirmed"] as! Bool
            historyLessonInfo.lessonType = tempDict["type"] as! NSInteger
            
            tempArray.add(historyLessonInfo)
        }
        return tempArray
    }

    
    class func getAvailableLessonInfo(_ arr : NSMutableArray) -> NSMutableArray {
        let tempArray = NSMutableArray()
        for case let tempDict as NSDictionary in arr {
            let availableLessonInfo = WLessonInfo()
            
            availableLessonInfo.lessonID = (tempDict["lessonId"] as! String)
            availableLessonInfo.studentID = (tempDict["studentId"] as! String)
            availableLessonInfo.driverID = (tempDict["driverId"] as? String ?? "")
            availableLessonInfo.locLat = tempDict["locLatitude"] as! Double
            availableLessonInfo.locLon = tempDict["locLongitude"] as! Double
            availableLessonInfo.isInstructorRequired = tempDict["instructorRequired"] as! Bool
            availableLessonInfo.isConfirmed = tempDict["confirmed"] as! Bool
            availableLessonInfo.lessonTimestamp = tempDict["utcDateTime"] as! Double
            availableLessonInfo.lessonType = tempDict["type"] as! NSInteger
            availableLessonInfo.lessonTag += 1
            tempArray.add(availableLessonInfo)
        }
        return tempArray
    }
    
    class func getLessonInfo(_ dict : NSMutableDictionary) -> WLessonInfo {
            let lessonInfo = WLessonInfo()
            
            lessonInfo.lessonID = dict["lessonId"] as! String
            lessonInfo.lessonHolderName = dict["firstName"] as! String
            lessonInfo.lessonHolderPic = String(format: "\(apiUrl)/images/%@", dict["pic"] as? String ?? "")
            lessonInfo.pic = dict["pic"] as? String ?? ""
            lessonInfo.studentID = dict["studentId"] as! String
            lessonInfo.driverID = dict["driverId"] as? String ?? ""
            lessonInfo.lessonDate = dict["dateTime"] as! String
            lessonInfo.locLat = dict["locLatitude"] as! Double
            lessonInfo.locLon = dict["locLongitude"] as! Double
            lessonInfo.lessonAmount = dict["amount"] as! Double
            lessonInfo.lessonDuration = dict["duration"] as! Double
            lessonInfo.isInstructorRequired = dict["instructorRequired"] as! Bool
            lessonInfo.studentStarted = dict["studentStarted"] as! Bool
            lessonInfo.driverStarted = dict["driverStarted"] as! Bool
            lessonInfo.finished = dict["finished"] as! Bool
            lessonInfo.paid = dict["paid"] as! Bool
            lessonInfo.lessonTimestamp = dict["utcDateTime"] as! Double
            lessonInfo.lessonStartTimestamp = dict["startedAtUtc"] as? Double ?? 0.0
            lessonInfo.studentRated = dict["studentRated"] as! Bool
            lessonInfo.driverRated = dict["driverRated"] as! Bool
            lessonInfo.lessonType = dict["type"] as! NSInteger
            lessonInfo.isConfirmed = dict["confirmed"] as! Bool
            lessonInfo.lessonHolderLicenseLevel = dict["licenseLevel"] as! String
        
        return lessonInfo
    }

}
