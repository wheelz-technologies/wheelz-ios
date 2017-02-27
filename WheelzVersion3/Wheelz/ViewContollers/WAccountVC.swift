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


class WAccountVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var userInfo = WUserInfo()
    var reviewsArray = NSMutableArray()
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var licenseNumberLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var lessonCountLabel: UILabel!
    @IBOutlet weak var staticLessonLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var hatImage: UIImageView!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var noReviewsLabel: UILabel!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callAPIForUserProfile()
        callAPIForGetReviews()
    }
    
    fileprivate func customInit() {
        self.reviewsTableView.rowHeight = 60
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
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WReviewTVCellID", for: indexPath) as! WReviewTVCell
        cell.contentView.backgroundColor = RGBA(255, g: 250, b: 250, a: 1)
        
        let userReview = reviewsArray.object(at: indexPath.row) as? WUserReview
         cell.textView.text = (userReview?.text)!
        
        switch userReview?.rating
        {
        case let x where x == 5:
            cell.ratingImageView.image = UIImage(named:"star5")!
            break
        case let x where x == 4:
            cell.ratingImageView.image = UIImage(named:"star4")!
            break
        case let x where x == 3:
            cell.ratingImageView.image = UIImage(named:"star3")!
            break
        case let x where x == 2:
            cell.ratingImageView.image = UIImage(named:"star2")!
            break
        case let x where x == 1:
            cell.ratingImageView.image = UIImage(named:"star1")!
            break
        default:
            cell.ratingImageView.image = UIImage(named:"star0")!
            break
        }
        
        //cell.delegate = self
        //cell.type = .slidingDoor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK:- Web API Section
    fileprivate func callAPIForGetReviews() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetReviews = kAPINameGetUserReviews(paramDict.value(forKey: WUserID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetReviews, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        self.noReviewsLabel.isHidden = false
                        
                        for constraint in self.view.constraints as [NSLayoutConstraint] {
                            if constraint.identifier == "viewBottomConstraint" {
                                constraint.constant = 0
                                self.view.layoutIfNeeded()
                                break
                            }
                        }
                        self.reviewsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
                    } else {
                        self.noReviewsLabel.isHidden = true
                        self.reviewsTableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
                    }
                    self.reviewsArray = WUserReview.getUserReviews(responseObject! as! NSMutableArray)
                    
                    self.reviewsTableView.reloadData()
                    
                }
            }
            
        }
    }
    
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
                            UserDefaults.standard.setValue(String(format: "\(apiUrl)/images/%@", (responseObject?.object(forKey: "pic") as? String)!), forKey: "wheelzUserPic")
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
                        
                        switch(self.userInfo.userLicenseLevel)
                        {
                            case "G1":
                                self.hatImage.image = UIImage(imageLiteralResourceName: "expLevelNovice")
                                break
                            case "G2":
                                self.hatImage.image = UIImage(imageLiteralResourceName: "expLevelExperienced")
                                break
                            case "G":
                                self.hatImage.image = UIImage(imageLiteralResourceName: "expLevelMaster")
                                break
                            default:
                                self.hatImage.isHidden = true
                                break
                        }
                        
                        self.licenseNumberLabel.text = self.userInfo.userLicenseNumber
                        self.lessonCountLabel.text = self.userInfo.lessonCount
                        getRoundImage(self.profileImgView)
                        self.staticLessonLabel.text = (self.userInfo.lessonCount as NSString).integerValue == 1 ? "LESSON" : "LESSONS"
                        if (self.userInfo.userImage != "") {
                            (self.profileImgView as! CustomImageView).customInit(self.userInfo.userImage)
                        } else {
                            self.profileImgView.layer.borderColor = UIColor.clear.cgColor
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
}
