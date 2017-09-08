//
//  ServiceHelper.swift
//  Fender
//
//  Created by Probir Chakraborty on 13/07/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

let baseURL: String = apiUrl

let timeoutInterval:Double = 45

enum loadingIndicatorType: CGFloat {
    
    case `default`  = 0 // showing indicator & text by disable UI
    case simple  = 1 // // showing indicator only by disable UI
    case noProgress  = 2 // without indicator by disable UI
    case smoothProgress  = 3 // without indicator by enable UI i.e No hud
}

enum MethodType: CGFloat {
    case get  = 0
    case post  = 1
    case put  = 2
    case delete  = 3
}

var hud_type: loadingIndicatorType = .default
var method_type: MethodType = .get

class ServiceHelper: NSObject {
    
    var tokenString = ""
    
    class var sharedInstance: ServiceHelper {
        struct Static {
            static let instance: ServiceHelper = ServiceHelper()
        }
        return Static.instance
    }
    
    //MARK:- Public Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    func callAPIWithParameters(_ parameterDict:NSMutableDictionary, method:MethodType, apiName :String, hudType:loadingIndicatorType, completionBlock: @escaping (AnyObject?, NSError?, Data?) -> Void) ->Void{
        
        hud_type = hudType
        
        if (kAppDelegate.isReachable() == false) {
            
            AlertController.alert("Connection Error", message: "It looks like you might be offline. Please check your Internet connection.")
            
            return
        }
        
        //>>>>>>>>>>> create post request
        let url = requestURL(method, apiName: apiName, parameterDict: parameterDict)
        print(url)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = methodName(method)
        
        //>>>>>>>>>>>> insert json data to the request
        request.httpBody = body(method, parameterDict: parameterDict)
        request.timeoutInterval = timeoutInterval
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(ftpName, forHTTPHeaderField: "username")
        request.setValue(ftpPass, forHTTPHeaderField: "password")
        
        //>>>>>>>>>>>>> set authentication credentials
        
        /*var appKey: String = KeychainWrapper.standard.string(forKey: "wheelzKey") ?? ""
        
        if (appKey.isEmpty) {
            let saveSuccessful: Bool = KeychainWrapper.standard.set("Some String", forKey: "myKey")
            appKey = ""
        }*/
        
        let loginString = String(format: "%@:%@", "B4753F3653FBF518A491A7D90551C2940D57E908C44B73D7762178769A92A874", "XlM6IQbalPp66llx9LnLtRoWGr5rvvL3Wg6o6ZJcbK7Ggdqhynarb3fRBQP3ZEE")
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
//        if isAuthTokenRequired(apiName) {
//            if let authTokenValue = NSUserDefaults.standardUserDefaults().valueForKey("auth_token") as? String {
//                
//                logInfo("jwtTokenValue    \(authTokenValue)")
//                
//                request.setValue(authTokenValue, forHTTPHeaderField: "Auth-Token")
//            } else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    //                    kAppDelegate.logOut()
//                })
//            }
//        }
        
        logInfo("\n\n Request URL  >>>>>>\(url)")
        //logInfo("\n\n Request Header >>>>>> \n\(request.allHTTPHeaderFields)")
        logInfo("\n\n Request Parameters >>>>>>\n\(parameterDict.toJsonString())")
        
        hideAllHuds(false, type:hudType)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data,response,error in
            
            hideAllHuds(true, type:hudType )
            
            if error != nil {
                logInfo("\n\n error  >>>>>>\n\(error)")
                
                completionBlock(nil,error as NSError?,data)
            } else {
                
                let httpResponse = response as! HTTPURLResponse
                let responseCode = httpResponse.statusCode

                let responseHeaderDict = httpResponse.allHeaderFields as NSDictionary
                logInfo("\n\n Response Header >>>>>> \n\(responseHeaderDict)")
                
                let responseString = String.init(data: data!, encoding: String.Encoding.utf8)
                
                logInfo("\n\n Response Code >>>>>> \n\(responseCode) \nResponse String>>>> \n \(responseString)")
//                dispatch_async(dispatch_get_main_queue()) {
//                    AlertController.alert("", message: responseString!)
//                }
                
//                   let message = NSDictionary(object: "OK",forKey: "Message")
                completionBlock(nil,error as NSError?,data)
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    DispatchQueue.main.async {
                        [weak self] in
                        logInfo("\n\n controller  >>>>>>\n\(self)")
                        completionBlock(result as AnyObject?,nil,data)
                    }
                    logInfo("\n\n Response >>>>>> \n\(result)")
                    
                } catch {
                    logInfo("\n\n error  >>>>>>\n\(error)")
                }
            }
        })
        
        task.resume()
    }
    
    //MARK:- Private Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    fileprivate func methodName(_ method:MethodType)-> String {
        
        switch method {
        case .get: return "GET"
        case .post: return "POST"
        case .delete: return "DELETE"
        case .put: return "PUT"
        }
    }
    
    fileprivate func body(_ method:MethodType, parameterDict:NSMutableDictionary) -> Data {
        
        switch method {
        case .get: return Data()
        case .post: return parameterDict.toNSData()
        case .put: return parameterDict.toNSData()
        default: return Data()
        }
    }
    
    fileprivate func requestURL(_ method:MethodType, apiName:String, parameterDict:NSMutableDictionary) -> URL {
        var urlString = baseURL + apiName
        if apiName == "getVehicleDetail" {
            urlString = "https://api.edmunds.com/api/vehicle/v2/makes?fmt=json&api_key=zsz9sex6ke8vk6dq9zz6zjzp"
        }
        
        if apiName == "getCityState" {
            urlString = "http://maps.googleapis.com/maps/api/geocode/json?address=&components=postal_code:\(parameterDict.value(forKey: "zipCode")!)&sensor=false"
        }
        
        print(urlString)
        switch method {
        case .get:
            if apiName == "getVehicleDetail" || apiName == "getCityState" {
                return URL(string: urlString)!
            }
            else {
                return getURL(apiName, parameterDict: parameterDict)
            }
        case .post:
            print(urlString)
            if apiName == kAPINameSignUp {
                return URL(string: urlString)!
            } else {
                return getURL(apiName, parameterDict: parameterDict)
            }
        case .put:
            if apiName == kAPINameUpdateUser()  || apiName == kAPINameUpdateLesson()  || apiName == kAPINameUpdateVehicle() || apiName == kAPINameRateLesson() {
                return URL(string: urlString)!
            } else {
                return getURL(apiName, parameterDict: parameterDict)
            }
        case .delete:
            return getURL(apiName, parameterDict: parameterDict)
            
//        default: return NSURL(string: urlString)!
        }
    }
    
    fileprivate func getURL(_ apiName:String, parameterDict:NSMutableDictionary) -> URL {
        
        var urlString = baseURL + apiName
        var isFirst = true
        
        for key in parameterDict.allKeys {
            
            let object = parameterDict[key as! String]
            
            if object is NSArray {
                
                let array = object as! NSArray
                for eachObject in array {
                    var appendedStr = "&"
                    if (isFirst == true) {
                        appendedStr = "?"
                    }
                    urlString += appendedStr + (key as! String) + "=" + (eachObject as! String)
                    isFirst = false
                }
                
            } else {
                var appendedStr = "&"
                if (isFirst == true) {
                    appendedStr = "?"
                }
                var parameterStr = String()
                
                //let theTrue = NSNumber(value: true as Bool)
                //let theFalse = NSNumber(value: false as Bool)
                
                for (key, value) in parameterDict {
                    switch value {
                    case let x where x is Bool:
                        parameterDict[key as! String] = "\(value as! Bool)"
                    case let x where x is Double:
                        parameterDict[key as! String] = "\(value as! Double)"
                    case let x where x is NSInteger:
                        parameterDict[key as! String] = "\(value as! NSInteger)"
                    default:
                        parameterDict[key as! String] = parameterDict[key as! String] as! String
                    }
                }
                
                parameterStr = parameterDict[key as! String] as! String
                urlString += appendedStr + (key as! String) + "=" + parameterStr
            }
            
            isFirst = false
        }
        let strUrl = urlString.addingPercentEscapes(using: String.Encoding.utf8)
        
//        let strUrl = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        
        return URL(string:strUrl!)!
    }
   /*
    func isAuthTokenRequired(apiName: String) -> Bool {
        var isRequired : Bool! = false
        
        if apiName == "profile" {
            isRequired = true
        }
        else if apiName == "change-phone" {
            isRequired = true
        }
        else if apiName == "change-phone-otp" {
            isRequired = true
        }
        else if apiName == "business-profile" {
            isRequired = true
        }
        else if apiName == "gcm-notification" {
            isRequired = true
        }
        else if apiName == "category" {
            isRequired = true
        }
        else if apiName == "type" {
            isRequired = true
        }
        else if apiName == "dashboard" {
            isRequired = true
        }
        else if apiName == "business-details" {
            isRequired = true
        }
        else if apiName == "update-business" {
            isRequired = true
        }
        else if apiName == "update-biz-type" {
            isRequired = true
        }
        else if apiName == "leads" {
            isRequired = true
        }
        else if apiName == "zoopup" {
            isRequired = true
        }
        else if apiName == "view_profile" {
            isRequired = true
        }
        else if apiName == "ask" {
            isRequired = true
        }
        else if apiName == "leads" {
            isRequired = true
        }
        else if apiName == "ping" {
            isRequired = true
        }
        else if apiName == "search" {
            isRequired = true
        }
        else if apiName == "connection" {
            isRequired = true
        }
        else if apiName == "notification" {
            isRequired = true
        }
        else if apiName == "get-profile" {
            isRequired = true
        }
        else if apiName == "logout" {
            isRequired = true
        }
        else if apiName == "nearby" {
            isRequired = true
        }
        
        return isRequired
    }
    */
}

private func hideAllHuds(_ status:Bool, type:loadingIndicatorType) {//UIApplication.sharedApplication().networkActivityIndicatorVisible = !status
    
    if (type == .smoothProgress) {
        return
    }
    
    PKHUD.sharedHUD.contentView = PKHUDProgressView()
    if (status == false) {
        if (type  == .noProgress) {
        } else {
            PKHUD.sharedHUD.show()
        }
        
    } else {
        DispatchQueue.main.async(execute: {
            PKHUD.sharedHUD.hide(afterDelay: 0.0)
        })
    }
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
extension NSDictionary {
    func toNSData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    func toJsonString() -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
    }
}
