//
//  WProfileVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-12-26.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class WProfileVC: UIViewController {
    
    var userInfo = WUserInfo()
    var lessonId = ""
    var userId = ""
    
    @IBOutlet weak var licenseLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var hatImgView: UIImageView!
    @IBOutlet weak var lessonCountLabel: UILabel!
    @IBOutlet weak var primaryCarLabel: UILabel!
    @IBOutlet weak var primaryCarTitleLabel: UILabel!
    @IBOutlet weak var primaryCarIcon: UIImageView!
    @IBOutlet weak var staticLessonLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!

    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callAPIForUserProfile()
    }
    
    fileprivate func customInit() {
        self.navigationItem.title = "User Profile"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        if(!lessonId.isEmpty)
        {
            //open previous navigation item and pop up a lesson screen
        } else {
            //open previous navigation item
            let drawerController = navigationController?.parent as! KYDrawerController
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForUserProfile() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = userId
        
        let apiNameGetUser = kAPINameGetUser(userId)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetUser, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    } else {
                        WAppData.appInfoSharedInstance.appUserInfo = WUserInfo.getUserInfo(responseObject!)
                        
                        self.userInfo =  WUserInfo.getUserInfo(responseObject!)
                        self.userNameLabel.text = self.userInfo.userName
                        self.licenseLabel.text = self.userInfo.userLicenseLevel
                        self.lessonCountLabel.text = self.userInfo.lessonCount
                        getRoundImage(self.profileImgView)
                        self.staticLessonLabel.text = (self.userInfo.lessonCount as NSString).integerValue == 1 ? "LESSON" : "LESSONS"
                        if (self.userInfo.userImage != "") {
                            (self.profileImgView as! CustomImageView).customInit(self.userInfo.userImage)
                        } else {
                            self.profileImgView.layer.borderColor = UIColor.clear.cgColor
                        }
                        
                        if(self.userInfo.isDriver)
                        {
                            if(self.userInfo.isRegisteredDriver)
                            {
                                self.hatImgView.isHidden = false
                            }
                            self.callApiToGetPrimaryCar(userId: self.userInfo.userID)
                        } else {
                            self.primaryCarIcon.isHidden = true
                            self.primaryCarLabel.isHidden = true
                            self.primaryCarTitleLabel.isHidden = true
                        }
                        
                        switch self.userInfo.userRating
                        {
                        case let x where x >= 4.8:
                            self.ratingImage.image = UIImage(named:"star5")!
                            break
                        case let x where x >= 4:
                            self.ratingImage.image = UIImage(named:"star4")!
                            break
                        case let x where x >= 3:
                            self.ratingImage.image = UIImage(named:"star3")!
                            break
                        case let x where x >= 2:
                            self.ratingImage.image = UIImage(named:"star2")!
                            break
                        case let x where x >= 1:
                            self.ratingImage.image = UIImage(named:"star1")!
                            break
                        default:
                            self.ratingImage.image = UIImage(named:"star0")!
                            break
                        }
                    }
                }
            }
        }
    }
    
    func callApiToGetPrimaryCar(userId: String)
    {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WDriverID] = userId
        
        let apiNameGetVehicle = kAPINameGetDriverVehicles(userId)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        self.primaryCarLabel.text = "None"
                    } else {
                        let vehiclesArray = WVehiclesInfo.getVehiclesInfo(responseObject! as! NSMutableArray)
                        
                        let primaryCar = vehiclesArray.filter{ ($0 as! WVehiclesInfo).isMain == true }.first as! WVehiclesInfo?
                        
                        if(primaryCar != nil)
                        {
                            self.primaryCarLabel.text = primaryCar!.year + " " + primaryCar!.make + " " + primaryCar!.model
                        }
                    }
                }
            }
        }
    }
}

