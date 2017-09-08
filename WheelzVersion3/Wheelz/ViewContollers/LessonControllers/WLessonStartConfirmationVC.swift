//
//  WLessonStartConfirmationVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-11-26.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WLessonStartConfirmationVC: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var userImageView: CustomImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var lessonCountLabel: UILabel!
    @IBOutlet weak var experienceLvlLabel: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var staticLessonLabel: UILabel!
    
    var lessonObj = WLessonInfo()
    var userInfo = WUserInfo()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Helper Methods
    func addSubviewWithBounce(_ theView : UIView)  {
        theView.alpha = 0;
        theView.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001);
        UIView.animate(withDuration: 0.6 ,
                       animations: {
                        theView.alpha = 1.0
        },
                       completion: { finish in
        })
        theView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0);
        let bounceAnimation =  CABasicAnimation(keyPath: "transform.scale")
        bounceAnimation.fromValue = 0.5
        bounceAnimation.toValue = 1.0
        bounceAnimation.duration = 0.7
        theView.layer.add(bounceAnimation, forKey: "bounce")
        theView.layer.transform = CATransform3DIdentity
    }
    
    func customInit() {
        callAPIForUserProfile()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(WLessonStartConfirmationVC.imageTapped))
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        // check if student has payments setup
        callAPIToCheckCards(confirmed: true)
    }

    @IBAction func startLaterBtnAction(_ sender: Any) {
        AlertController.alert("Reject claim", message: "Rejecting this driver's claim will remove him or her from this lesson. Are you sure?",controller: (kAppDelegate.window?.rootViewController)!, buttons: ["Cancel","Yes, reject"], tapBlock: { (alertAction, position) -> Void in
            if position == 1 {
                self.callAPIToConfirmRejectLesson(confirmed: false)
            }
        })
    }
    
    func imageTapped()
    {
    let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
    let userProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WProfileVCID") as! WProfileVC
    userProfileView.lessonId = lessonObj.lessonID

    //driver account should be opened
    userProfileView.userId = lessonObj.driverID
    (drawerController.mainViewController as! UINavigationController).pushViewController(userProfileView, animated: true)
    self.removeFromSuperview()
    }
    
    // MARK - Web API methods
    fileprivate func callAPIForUserProfile() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = self.lessonObj.driverID
        
        let apiNameGetUser = kAPINameGetUser(self.lessonObj.driverID)
        
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
                        
                        self.lessonCountLabel.text = self.userInfo.lessonCount
                        getRoundImage(self.userImageView)
                        self.staticLessonLabel.text = (self.userInfo.lessonCount as NSString).integerValue == 1 ? "LESSON" : "LESSONS"
                        if (self.userInfo.userImage != "") {
                            (self.userImageView as CustomImageView).customInit(self.userInfo.userImage)
                        } else {
                            self.userImageView.layer.borderColor = UIColor.clear.cgColor
                        }
                        
                        switch(self.userInfo.userLicenseLevel)
                        {
                        case "G1":
                            self.experienceLvlLabel.image = UIImage(imageLiteralResourceName: "expLevelNovice")
                            break
                        case "G2":
                            self.experienceLvlLabel.image = UIImage(imageLiteralResourceName: "expLevelExperienced")
                            break
                        case "G":
                            self.experienceLvlLabel.image = UIImage(imageLiteralResourceName: "expLevelMaster")
                            break
                        default:
                            self.experienceLvlLabel.isHidden = true
                            break
                        }
                        
                        switch self.userInfo.userRating
                        {
                        case let x where x >= 4.8:
                            self.ratingImageView.image = UIImage(named:"star5")!
                            break
                        case let x where x >= 4:
                            self.ratingImageView.image = UIImage(named:"star4")!
                            break
                        case let x where x >= 3:
                            self.ratingImageView.image = UIImage(named:"star3")!
                            break
                        case let x where x >= 2:
                            self.ratingImageView.image = UIImage(named:"star2")!
                            break
                        case let x where x >= 1:
                            self.ratingImageView.image = UIImage(named:"star1")!
                            break
                        default:
                            self.ratingImageView.image = UIImage(named:"star0")!
                            break
                        }
                    }
                }
            }
        }
    }
    
    func callAPIToConfirmRejectLesson(confirmed: Bool) {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WConfirmed] = confirmed
        
        let apiNameConfirmRejectLesson = kAPINameConfirmRejectLesson(lessonObj.lessonID, isConfirmed: confirmed)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameConfirmRejectLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" && confirmed {
                        let lessonTipVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WConfirmationTipVCID") as! WLessonTipVC
                           
                        self.removeFromSuperview()
                        kAppDelegate.window?.rootViewController!.present(lessonTipVc, animated: true, completion: nil)
                    } else {
                        self.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func callAPIToCheckCards(confirmed: Bool)
    {
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetCards = kAPINameGetAllCards(paramDict.value(forKey: WUserID) as! String)
        let parentController = UIApplication.shared.keyWindow?.rootViewController
        
        //create dialog window
        let alert = UIAlertController(title: "Payment method", message: "It looks like you haven't added any payment methods yet. Please add one before confirming a lesson!", preferredStyle: .alert)
        
        //setup actions
        let setupPaymentsAction = UIAlertAction(title: "Add Card", style: .default, handler: { (action: UIAlertAction!) -> Void in
            
            let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
            let paymentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WPaymentsVCID") as! WPaymentsVC
            
            drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
            drawerController.setDrawerState(.closed, animated: true)
            self.removeFromSuperview()
        })
        let defaultAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        //add actions to the dialog
        alert.addAction(defaultAction)
        alert.addAction(setupPaymentsAction)

        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetCards, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    
                    //if there is a payment method already
                    if (tempArray != nil && tempArray!.count >= 1) {
                        self.callAPIToConfirmRejectLesson(confirmed: confirmed)
                    } else {
                        //if there are no payment methods setup
                        parentController!.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

}
