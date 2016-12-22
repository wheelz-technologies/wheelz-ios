//
//  WAccountController.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
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


class WAccountVC: UIViewController {

    var userInfo = WUserInfo()
    
    @IBOutlet weak var licenseLevelLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var licenseNumberLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var lessonCountLabel: UILabel!
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
        self.navigationItem.title = "Account"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("edit_w", controller: self)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        let editProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "WEditProfileVCID") as! WEditProfileVC
        editProfileVC.userObj = userInfo
        self.navigationController?.pushViewController(editProfileVC, animated: true)
    }

    //MARK:- Web API Section
    fileprivate func callAPIForUserProfile() {
        
        let paramDict = NSMutableDictionary()

        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
//        paramDict[WUserPassword] = userInfo.userPasswordHash
        
        let apiNameGetUser = kAPINameGetUser((UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!)
        
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
                        UserDefaults.standard.setValue(((responseObject!.object(forKey: "firstName") as! String)), forKey: "wheelzUserName")
                        UserDefaults.standard.setValue(((responseObject!.object(forKey: "password") as! String)), forKey: "wheelzUserPassword")
                        UserDefaults.standard.set(responseObject?.object(forKey: "isInstructor") as? Bool ?? false, forKey: "wheelzIsInstructor")
                        if responseObject?.object(forKey: "pic") as? String != nil  {
                            UserDefaults.standard.setValue(String(format: "https://soireedev.azurewebsites.net/images/%@", (responseObject?.object(forKey: "pic") as? String)!), forKey: "wheelzUserPic")
                        } else {
                            UserDefaults.standard.setValue("", forKey: "wheelzUserPic")
                        }
                        UserDefaults.standard.synchronize()
                        WAppData.appInfoSharedInstance.appUserInfo = WUserInfo.getUserInfo(responseObject!)
                        
                        self.userInfo =  WUserInfo.getUserInfo(responseObject!)
                        self.userNameLabel.text = self.userInfo.userName
                        self.userEmailLabel.text = self.userInfo.userEmail
                        self.contactLabel.text = self.userInfo.userPhone
                        if self.userInfo.userPhone == "" {
                            self.contactLabel.text = "Not available"
                        }
                        self.licenseLevelLabel.text = self.userInfo.userLicenseLevel
                        self.licenseNumberLabel.text = self.userInfo.userLicenseNumber
                        self.lessonCountLabel.text = self.userInfo.lessonCount
                        getRoundImage(self.profileImgView)
                        self.staticLessonLabel.text = (self.userInfo.lessonCount as NSString).integerValue == 1 ? "LESSON" : "LESSONS"
                        //self.profileImgView.setImageWithUrl(NSURL(string: self.userInfo.userImage)!, placeHolderImage: UIImage(named: "default.png"))
                        if (self.userInfo.userImage != "") {
                            //self.profileImgView.layer.borderColor = UIColor.gray.cgColor
                            //self.profileImgView.layer.borderWidth = 2.0
                            (self.profileImgView as! CustomImageView).customInit(self.userInfo.userImage)
                        } else {
                            self.profileImgView.layer.borderColor = UIColor.clear.cgColor
                        }
                        if self.userEmailLabel.text?.length > 20 {
                            self.userEmailLabel.font = kAppFont(15)
                            self.contactLabel.font = kAppFont(15)
                            self.licenseNumberLabel.font = kAppFont(15)
                            self.licenseLevelLabel.font = kAppFont(15)
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
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
//                        }
                    }
                }
            }
            
        }
    }

}
