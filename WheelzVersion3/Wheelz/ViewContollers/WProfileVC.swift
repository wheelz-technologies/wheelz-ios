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


class WProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userInfo = WUserInfo()
    var reviewsArray = NSMutableArray()
    var lessonId = ""
    var userId = ""
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var hatImgView: UIImageView!
    @IBOutlet weak var lessonCountLabel: UILabel!
    @IBOutlet weak var primaryCarLabel: UILabel!
    @IBOutlet weak var staticLessonLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var noReviewsLabel: UILabel!
    @IBOutlet weak var reviewsTableView: UITableView!
    @IBOutlet weak var carImageView: UIImageView!
    
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
        self.navigationItem.title = "User Profile"
        //self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("backArrow", controller: self)
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        //self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("messageUserIcon", controller: self)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        self.view.endEditing(true)
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
        if(!lessonId.isEmpty)
        {
            let lessonDetailView = Bundle.main.loadNibNamed("WLessonDetailView", owner: nil, options: nil)?[0] as! WLessonDetailView
            
            lessonDetailView.lessonID = lessonId
            lessonDetailView.customInit()
            lessonDetailView.frame = (kAppDelegate.window?.bounds)!
            lessonDetailView.delegate = self.navigationController!.viewControllers[self.navigationController!.viewControllers.count - 1] as! WHistoryVC
            kAppDelegate.window?.rootViewController!.view.addSubview(lessonDetailView)
        }
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        //TO DO: implement messaging feature
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
        
        cell.type = .slidingDoor
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForGetReviews() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = userId
        
        let apiNameGetReviews = kAPINameGetUserReviews(paramDict.value(forKey: WUserID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetReviews, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        self.noReviewsLabel.isHidden = false
                        self.reviewsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
                        self.reviewsTableView.separatorColor = UIColor.white
                        
                            for constraint in self.view.constraints as [NSLayoutConstraint] {
                                if constraint.identifier == "viewBottomConstraint" {
                                    constraint.constant = -100
                                    self.view.layoutIfNeeded()
                                    break
                                }
                        }
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
                            self.callApiToGetPrimaryCar(userId: self.userInfo.userID)
                        } else {
                            self.primaryCarLabel.isHidden = true
                            self.carImageView.image = UIImage(named: "wheelOnly.png")
                            self.carImageView.contentMode = UIViewContentMode.scaleAspectFit
                        }
                        
                        switch(self.userInfo.userLicenseLevel)
                        {
                        case "G1":
                            self.hatImgView.image = UIImage(imageLiteralResourceName: "expLevelNovice")
                            break
                        case "G2":
                            self.hatImgView.image = UIImage(imageLiteralResourceName: "expLevelExperienced")
                            break
                        case "G":
                            self.hatImgView.image = UIImage(imageLiteralResourceName: "expLevelMaster")
                            break
                        default:
                            self.hatImgView.isHidden = true
                            break
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
                            self.carImageView.setImageWithUrl(URL(string: primaryCar!.carImage)!, placeHolderImage: UIImage(named: "carPicProfile.png"))
                            self.carImageView.contentMode = UIViewContentMode.scaleAspectFill
                        }
                    }
                }
            }
        }
    }
}

