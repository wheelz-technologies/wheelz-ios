//
//  WVehiclesInfo.swift
//  Wheelz
//
//  Created by PROBIR CHAKRABORTY on 28/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WVehiclesInfo: NSObject {

    var vehicleId : String = ""
    var driverId : String = ""
    var make : String = ""
    var model : String = ""
    var year : String = ""
     var createYear : NSInteger = 0
    var vin : String = ""
    var isAvailableForTest : Bool = false
    var isMain : Bool = false
    var modelArray:NSMutableArray = []
    var yearArray:NSMutableArray = []
    var transType: String = ""
    var carImage : String = ""
    var carImageFileName : String = ""
    
    class func getVehiclesInfo(_ arr : NSMutableArray) -> NSMutableArray {
        let tempArray = NSMutableArray()
        for case let tempDict as NSDictionary in arr {
            let vehiclesInfo = WVehiclesInfo()
            vehiclesInfo.vehicleId = tempDict["vehicleId"] as! String
            vehiclesInfo.make = tempDict["make"] as! String
            vehiclesInfo.model = tempDict["model"] as! String
            vehiclesInfo.year = String(format: "%d", tempDict["year"] as? NSInteger ?? 0)
            vehiclesInfo.transType = tempDict["transmissionType"] as! String
            vehiclesInfo.vin = tempDict["vin"] as? String ?? ""
            vehiclesInfo.isMain = tempDict["isMain"] as! Bool
            vehiclesInfo.isAvailableForTest = tempDict["availableForTest"] as! Bool
            vehiclesInfo.carImage = String(format: "\(apiUrl)/images/%@", tempDict["pic"] as? String ?? "")
            vehiclesInfo.carImageFileName = tempDict["pic"] as? String ?? ""
            tempArray.add(vehiclesInfo)
        }
        return tempArray
    }
    
    class func getVehiclesDetail(_ response : NSMutableDictionary) -> NSMutableArray {
        let makeArray = NSMutableArray()
        for case let tempDict as NSDictionary in  response["makes"] as! NSMutableArray{
            let makeInfo = WVehiclesInfo()
            makeInfo.make = tempDict["name"] as! String
            makeInfo.modelArray = NSMutableArray()
            for case let modelDict as NSDictionary in tempDict["models"] as! NSMutableArray {
                let modelInfo = WVehiclesInfo()
                modelInfo.model = modelDict["name"] as! String
                modelInfo.yearArray = NSMutableArray()
                for case let yearDict as NSDictionary in modelDict["years"] as! NSMutableArray {
                    let yearInfo = WVehiclesInfo()
                    yearInfo.year = String(format: "%d",yearDict["year"] as? NSInteger ?? 0)
                    print("year=>",yearInfo.year)
                    modelInfo.yearArray.add(yearInfo)
                }
                makeInfo.modelArray.add(modelInfo)
            }
            makeArray.add(makeInfo)
        }
        return makeArray
    }
    
}
