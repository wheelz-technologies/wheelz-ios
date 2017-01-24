//
//  WLessonDetailView.swift
//  Wheelz
//
//  Created by Neha Chhabra on 08/09/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

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


@objc protocol lessonDetailDelegate{
    @objc optional func removeViewWithLessonobj(_ lessonObj : WLessonInfo, isEdit : Bool,msg : String)
}

class WLessonDetailView: UIView ,MKMapViewDelegate {

    var delegate: lessonDetailDelegate?
    
    @IBOutlet weak var userPicImageView: UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var claimLessonButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var addressDetailsLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var backArrowBtn: UIButton!
    
    @IBOutlet weak var forwardArrowBtn: UIButton!
    
    @IBOutlet weak var userTypeLabel: UILabel!
    
    @IBOutlet weak var hatImage: UIImageView!
    
    @IBOutlet weak var awaitingConfIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var awaitingConfLabel: UILabel!
    
    var lessonObj = WLessonInfo()
    var driverInfo: WUserInfo? = nil
    var latDelta:CLLocationDegrees = 0.001
    var longDelta:CLLocationDegrees = 0.001
    var lessonID : String!
    let isDriver = UserDefaults.standard.value(forKey: "wheelzIsDriver") as! Bool
    var userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? ""
    var fromHistory = false;
    var driverSelected = false;
    var isFirstLesson: Bool = false
    
    var updateTimer: Timer?
    
    @IBOutlet weak var lessonView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //addSubviewWithBounce(lessonView)
        setUpOnLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        // Scheduling timer to update lesson info with the interval of 10 seconds
        self.updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(WLessonDetailView.checkLessonStatus), userInfo: nil, repeats: true)
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
        theView.layer.transform = CATransform3DIdentity;
    }
    
    func customInit () {
        callAPIForGetLessons(lessonID)
        self.claimLessonButton.isHidden = true
        self.cancelButton.isHidden = true
//        getRoundImage(self.userPicImageView)
       self.userPicImageView.layer.cornerRadius = self.userPicImageView.frame.size.width/2
        self.userPicImageView.clipsToBounds = true
        self.userPicImageView.layer.masksToBounds = true
    }
    
    @objc func applicationDidBecomeActive() {
        self.customInit()
    }
    
    func rightBarButtonAction(_ button : UIButton) {
//        let editLessonVC = self.storyboard?.instantiateViewControllerWithIdentifier("WEditLessonVCID") as! WEditLessonVC
//        editLessonVC.lessonObj = lessonObj
//        self.navigationController?.pushViewController(editLessonVC, animated: true)
    }
    
    func setUpOnLoad()  {
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(CLLocation(latitude:  lessonObj.locLat, longitude:  lessonObj.locLon).coordinate, span)
        mapView.setRegion(region, animated: true)
        let newCamera = MKMapCamera()
        newCamera.heading = self.mapView.camera.heading;
        newCamera.altitude = self.mapView.camera.altitude;
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove)
        mapView.showsUserLocation = true
        
        let loc = CLLocation(latitude: lessonObj.locLat, longitude: lessonObj.locLon)
        let lessonPosition = WCustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        lessonPosition.title = getDateFromTimeStamp(lessonObj.lessonTimestamp)
        lessonPosition.subtitle = getTimeFromTimeStamp(lessonObj.lessonTimestamp)
        lessonPosition.lessonID = lessonObj.lessonID
        lessonPosition.driverID = lessonObj.driverID
        lessonPosition.isInstructorRequired = lessonObj.isInstructorRequired
        newCamera.centerCoordinate = lessonPosition.coordinate
        mapView.addAnnotation(lessonPosition)
        mapView.layer.borderColor = UIColor.lightGray.cgColor
        mapView.layer.borderWidth = 1.0;
        
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        if (self.lessonObj.studentStarted && self.lessonObj.driverStarted && !self.lessonObj.finished) {
            //if started by both student and driver, redirect to Lesson Tracking
            let lessonTrackingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLessonTrackingVCID") as! WLessonTrackingVC
            lessonTrackingView.lessonObj = self.lessonObj
            
            drawerController.mainViewController = UINavigationController(rootViewController : lessonTrackingView)
            drawerController.setDrawerState(.closed, animated: true)
            
            delegate?.removeViewWithLessonobj!(lessonObj, isEdit : false,msg:"")
        } /*else if ((self.isDriver && self.lessonObj.studentStarted && !self.lessonObj.driverStarted) || (!self.isDriver && !self.lessonObj.studentStarted && self.lessonObj.driverStarted)) {
            let confirmLessonView = Bundle.main.loadNibNamed("WLessonStartConfirmationVC", owner: nil, options: nil)?[0] as! WLessonStartConfirmationVC
            confirmLessonView.lessonObj = self.lessonObj
            confirmLessonView.customInit()
            confirmLessonView.frame = (kAppDelegate.window?.bounds)!
            
            kAppDelegate.window?.rootViewController!.view.addSubview(confirmLessonView)
        }*/ else if (self.lessonObj.finished && self.lessonObj.paid && (!self.isDriver && !self.lessonObj.studentRated || self.isDriver && !self.lessonObj.driverRated)) {
            //redirect to Rate screen
            
            let rateLessonView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WRateLessonVCID") as! WRateLessonVC
            rateLessonView.lessonObj = self.lessonObj
            
            drawerController.mainViewController = UINavigationController(rootViewController : rateLessonView)
            drawerController.setDrawerState(.closed, animated: true)
            
            delegate?.removeViewWithLessonobj!(lessonObj, isEdit : false,msg:"")
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(WLessonDetailView.imageTapped))
        userPicImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if(!lessonObj.driverID.isEmpty) {
            let backArrowGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(WLessonDetailView.switchUserInfo))
            let forwardArrowGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(WLessonDetailView.switchUserInfo))
            backArrowBtn.addGestureRecognizer(backArrowGestureRecognizer)
            forwardArrowBtn.addGestureRecognizer(forwardArrowGestureRecognizer)
            backArrowBtn.isHidden = false
            forwardArrowBtn.isHidden = false
            userTypeLabel.isHidden = false
        } else {
            backArrowBtn.isHidden = true
            forwardArrowBtn.isHidden = true
            userTypeLabel.isHidden = true
        }
        
        getLessonCount()
    }
    
    func checkLessonStatus() {
        callAPIForGetLessons(lessonObj.lessonID)
    }
    
    func switchUserInfo()
    {
        if(driverSelected)
        {
            self.userNameLabel.text = self.lessonObj.lessonHolderName
            self.userPicImageView.setImageWithUrl(URL(string: self.lessonObj.lessonHolderPic)!, placeHolderImage: UIImage(named: "userPic"))
            self.hatImage.isHidden = true
            self.userTypeLabel.text = "Student"
            driverSelected = false
        } else {
            callAPIToGetUserInfo(userId: lessonObj.driverID)
        }
    }
    
    func imageTapped()
    {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        let userProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WProfileVCID") as! WProfileVC
        userProfileView.lessonId = lessonObj.lessonID
        
        if(self.driverSelected)
        {
            if(lessonObj.driverID == userId)
            {
                //do nothing for now? Later open own account screen
                return
            }
            //student account should be opened
            userProfileView.userId = lessonObj.driverID
            
        } else {
            if(lessonObj.studentID == userId)
            {
                //do nothing for now? Later open own account screen
                return
            }
            //driver account should be opened
            userProfileView.userId = lessonObj.studentID
        }
        (drawerController.mainViewController as! UINavigationController).pushViewController(userProfileView, animated: true)
        
        delegate?.removeViewWithLessonobj!(lessonObj, isEdit : false,msg:"")
    }
    
    func getDateFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let str = dateFormatter.string(from: date)
        if str.hasPrefix("0") {
            
            return (str as NSString).replacingCharacters(in: NSMakeRange(0, 1), with: "")
        }
        return dateFormatter.string(from: date)
    }
    
    func getTimeFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    func getExactTime(_ value : String) -> String {
        var strDate =  value.replacingOccurrences(of: ".", with: ":")
        strDate = strDate.replacingOccurrences(of: "25", with: "15")
        strDate = strDate.replacingOccurrences(of: "50", with: "30")
        strDate = strDate.replacingOccurrences(of: "75", with: "45")
        let attStr = strDate.components(separatedBy: ":")
        if (attStr.last! as NSString).integerValue  == 0  {
            if (attStr.first! as NSString).integerValue > 1 {
                return String(format: "%@ hours", attStr.first!)
            } else {
                return String(format: "%@ hour", attStr.first!)
            }
        } else {
            if (attStr.first! as NSString).integerValue > 1 {
            return  String(format: "%@ hours %@ minutes", attStr.first!,attStr.last!)
            } else if (attStr.first! as NSString).integerValue == 1{
                return  String(format: "%@ hour %@ minutes", attStr.first!,attStr.last!)
            } else {
                return  String(format: "%@ minutes",attStr.last!)
            }
        }
    }
    
    //MARK:- MapView Delegates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is WCustomAnnotation) {
            return nil
        }
        let getLat: CLLocationDegrees = lessonObj.locLat
        let getLon: CLLocationDegrees = lessonObj.locLon
            
        let annLocation: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)
            
        self.getAddressFromLocation((annLocation), completion: { (address:String?) in
            if (address != nil) {
                (annotation as! WCustomAnnotation).title = address
            } else {
                (annotation as! WCustomAnnotation).title = "Whoops, we can't find that address :("
            }
        })
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            anView!.canShowCallout = true
        } else {
            anView!.annotation = annotation
        }

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        imageView.image = UIImage(named: "wheelzOrange");
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            
            //if lesson is claimed by the active user (driver), show green icon
            if((annotation as! WCustomAnnotation).driverID == userId) {
                    imageView.image = UIImage(named: "wheelzGreen");
            } else
                //if instructor is required, show blue icon, else show orange
                if ((annotation as! WCustomAnnotation).isInstructorRequired) {
                    imageView.image = UIImage(named: "wheelzBlue");
            }
        } else {
            //if lesson is claimed, show blue icon, else show orange
            if (!(annotation as! WCustomAnnotation).driverID.isEmpty) {
                    imageView.image = UIImage(named: "wheelzBlue");
            }
        }
        
        imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
        imageView.layer.masksToBounds = true
        
        anView!.calloutOffset = CGPoint(x: -35, y: -35)
        anView!.frame = imageView.frame
        anView!.addSubview(imageView)
        
        return anView
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func editLessonButtonAction(_ sender: UIButton) {
        if(self.claimLessonButton.titleLabel?.text == "START LESSON") {
            if self.lessonObj.lessonTimestamp > Date().addingTimeInterval(600).timeIntervalSince1970 {
                //the lesson is more than 10 minutes from now
                presentFancyAlert("A bit too soon!", msgStr: "You can only start your lesson within 10 minutes of scheduled time.", type: AlertStyle.Info, controller: self)
                return
            } else {
                callAPIToStartLesson()
                return
            }
        }
        
        if (self.isDriver) == true {
            //before claiming the lesson, check if driver finished his payments setup, otherwise display the warning message
            callAPIForPaymentSetupDetails()
            //verify that driver has vehicles attached to his account, otherwise he must add one
        } else {
            delegate?.removeViewWithLessonobj!(lessonObj, isEdit : true,msg:"")
        }
    }
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
         delegate?.removeViewWithLessonobj!(lessonObj, isEdit : false,msg:"")
    }
    
    @IBAction func cancelLessonButtonAction(_ sender: UIButton) {
        if (isDriver) == true {
            AlertController.alert("", message: "Cancel your lesson claim?",controller: (kAppDelegate.navController)!, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
                if position == 1 {
                     self.callAPIForUnclaimLessons()
                }
            })
        } else {
            AlertController.alert("", message: "Cancel your lesson request?",controller: (kAppDelegate.navController)!, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
                if position == 1 {
                    self.callAPIForDeleteLessons()
             }
            })

        }
    }
    
    // MARK: Private methods
    
    fileprivate func hideCancelButton() {
        for subview in self.subviews {
            for constraint in subview.constraints as [NSLayoutConstraint] {
                if constraint.identifier == "claimBtnBottomConstraint" {
                    constraint.constant = -45
                    self.layoutIfNeeded()
                    break
                }
            }
        }
       self.cancelButton.isHidden = true
    }
    
    
    func getAddressFromLocation(_ loc : CLLocation,completion:@escaping (String?) -> Void) {
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                if let addressDic = pm.addressDictionary {
                    if let lines = addressDic["FormattedAddressLines"] as? [String] {
                        completion(lines.joined(separator: ", "))
                    } else {
                        // fallback
                        if #available(iOS 9.0, *) {
                            completion (CNPostalAddressFormatter.string(from: self.postalAddressFromAddressDictionary(pm.addressDictionary! as! Dictionary<String, String>), style: .mailingAddress))
                        } else {
                            completion(ABCreateStringWithAddressDictionary(pm.addressDictionary!, false))
                        }
                    }
                } else {
                    return
                }
                
            } else {
                print("Problem with the data received from geocoder")
                return
            }
        })
    }
    
    @available(iOS 9.0, *)
    func postalAddressFromAddressDictionary(_ addressdictionary: Dictionary<String,String>) -> CNMutablePostalAddress {
        
        let address = CNMutablePostalAddress()
        
        address.street = addressdictionary["Street"] ?? ""
        address.state = addressdictionary["State"] ?? ""
        address.city = addressdictionary["City"] ?? ""
        address.country = addressdictionary["Country"] ?? ""
        address.postalCode = addressdictionary["ZIP"] ?? ""
        
        return address
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForGetLessons(_ lessonID : String) {
        
        let paramDict = NSMutableDictionary()
        
        let apiNameGetLesson = kAPINameGetLesson(lessonID)
        paramDict[WLessonID] = lessonID
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    kAppDelegate.isFirstLoad = true
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:message)
                                                        } else {
                        self.lessonObj = WLessonInfo.getLessonInfo(responseObject! as! NSMutableDictionary)
                        self.durationLabel.text = self.getExactTime(String(format:"%.2f", self.lessonObj.lessonDuration))
                        self.userNameLabel.text = self.lessonObj.lessonHolderName                        
                        self.userPicImageView.setImageWithUrl(URL(string: self.lessonObj.lessonHolderPic)!, placeHolderImage: UIImage(named: "userPic"))
                        
                        //self.userPicImageView.layer.borderColor = UIColor.lightGray.cgColor
                        //self.userPicImageView.layer.borderWidth = 2.0
                        
                        if (self.lessonObj.lessonHolderPic != "") {
                            (self.userPicImageView as! CustomImageView).customInit(self.lessonObj.lessonHolderPic)
                        }
                        self.timeLabel.text = self.getTimeFromTimeStamp(self.lessonObj.lessonTimestamp)
                        self.dateLabel.text = self.getDateFromTimeStamp(self.lessonObj.lessonTimestamp)

                        /*DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
                            for i in stride(from: 0, to: self.lessonObj.lessonAmount + 1, by: 1) {
                                usleep(40000); // sleep in microseconds
                                DispatchQueue.main.async(execute: {
                                       self.priceLabel.text = String(format:"$%.0f", i)
                                    });
                            }
                            DispatchQueue.main.async(execute: {
                                self.priceLabel.text = String(format:"$%.0f", self.lessonObj.lessonAmount)
                            });
                        }) */
                        
                        DispatchQueue.main.async(execute: {
                            self.priceLabel.text = String(format:"$%.0f", self.lessonObj.lessonAmount)
                        });
                        
                        if(self.lessonObj.finished)
                        {
                            self.claimLessonButton.isHidden = true
                            self.cancelButton.isHidden = true
                        } else {
                        if (self.isDriver) == true {
                            if(self.lessonObj.driverID == "") {
                                self.claimLessonButton.setTitle("CLAIM", for: UIControlState())
                                self.claimLessonButton.isHidden = false
                                self.hideCancelButton()
                            } else {
                                self.claimLessonButton.setTitle("START LESSON", for: UIControlState())
                                self.claimLessonButton.isHidden = false
                                self.claimLessonButton.backgroundColor = UIColor.lightGray
                                
                                if self.lessonObj.lessonTimestamp > Date().addingTimeInterval(600).timeIntervalSince1970 {
                                    //if the lesson more than 10 minutes from now
                                    self.cancelButton.isHidden = false
                                } else {
                                    self.hideCancelButton()
                                    if(!self.lessonObj.driverStarted) {
                                        self.claimLessonButton.isEnabled = true
                                        self.claimLessonButton.backgroundColor = kAppLightBlueColor
                                    } else {
                                        //if lesson is already started by user (driver)
                                        self.claimLessonButton.isHidden = true
                                        if(!self.lessonObj.studentStarted) {
                                            self.awaitingConfLabel.isHidden = false
                                            self.awaitingConfIndicator.isHidden = false
                                        }
                                    }
                                  }
                              }
                        } else {
                            if(self.lessonObj.driverID == "") {
                                self.claimLessonButton.setTitle("EDIT", for: UIControlState())
                                self.claimLessonButton.isHidden = false
                                self.cancelButton.isHidden = false
                            } else {
                                self.claimLessonButton.setTitle("START LESSON", for: UIControlState())
                                self.claimLessonButton.isHidden = false
                                self.claimLessonButton.backgroundColor = UIColor.lightGray
                                
                                if self.lessonObj.lessonTimestamp > Date().addingTimeInterval(600).timeIntervalSince1970 {
                                    //if the lesson more than 10 minutes from now
                                    self.cancelButton.isHidden = false
                                } else {
                                    self.hideCancelButton()
                                        if(!self.lessonObj.studentStarted) {
                                            self.claimLessonButton.isEnabled = true
                                            self.claimLessonButton.backgroundColor = kAppLightBlueColor
                                        } else {
                                            //if lesson is already started by user (student)
                                            self.claimLessonButton.isHidden = true
                                            if(!self.lessonObj.driverStarted) {
                                                self.awaitingConfLabel.isHidden = false
                                                self.awaitingConfIndicator.isHidden = false
                                            }
                                        }
                                }
                            }
                            }
                        }
                        self.mapView.delegate = self
                        self.setUpOnLoad()
                    }
                }
            }
            
        }
    }
    
    fileprivate func callAPIForClaimLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WDriverID] = userId
        
        let apiNameClaimLesson = kAPINameClaimLesson(lessonObj.lessonID, driverId: userId)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameClaimLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        if(self.isFirstLesson)
                        {
                            let firstLessonTipVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                            firstLessonTipVc.orderedViewControllers = [newViewControllerFromMain(name: "WDriverLessonTip1VCID"),
                                                                       newViewControllerFromMain(name: "WDriverLessonTip2VCID"),
                                                                       newViewControllerFromMain(name: "WStartLessonTipVCID"),
                                                                       newViewControllerFromMain(name: "WTrackingLessonTipVCID"),
                                                                       newViewControllerFromMain(name: "WRateLessonTipVCID")]
                            
                            self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg: "")
                            kAppDelegate.window?.rootViewController!.present(firstLessonTipVc, animated: true, completion: nil)
                        } else {
                            let lessonTipVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLessonTipVCID") as! WLessonTipVC
                            lessonTipVc.isDriver = true;
                            
                            self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg: "")
                            kAppDelegate.window?.rootViewController!.present(lessonTipVc, animated: true, completion: nil)
                        }
                    } else {
                        let message = responseObject?.object(forKey: "Message") as? String ?? ""
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg: message)
                        return
                    }
                    }
                }
            }
        }
    
    fileprivate func callAPIForDeleteLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        
        let apiNameDeleteLesson = kAPINameDeleteLesson(lessonObj.lessonID)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .delete, apiName: apiNameDeleteLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:"")
                    } else {
                        let message = responseObject?.object(forKey: "Message") as? String ?? ""
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:message)
                    }
                }
            }
            
        }
    }
    
    fileprivate func callAPIForUnclaimLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WDriverID] = userId
        
        let apiNameUnclaimLesson = kAPINameUnclaimLesson(lessonObj.lessonID, driverId: userId)
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUnclaimLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:"")
                    } else {
                          let message = responseObject?.object(forKey: "Message") as? String ?? ""
                          self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg : message)
                    }
                }
            }
            
        }
    }

    fileprivate func callAPIForPaymentSetupDetails() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = userId
        
        let parentController = UIApplication.shared.keyWindow?.rootViewController
        
        let apiNameGetSetupDetails = kAPINameGetSetupDetails(userId)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetSetupDetails, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
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
                        if(WPaymentSetupDetails.getPaymentSetupDetails(responseObject!).status == "unverified" &&
                           WPaymentSetupDetails.getPaymentSetupDetails(responseObject!).details != "identity document required") {
                            AlertController.alert("Payments setup", message: "It looks like you haven't set up your payments yet and might not be able to receive money for this lesson. Set up now?",controller: parentController!, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
                                if position == 1 {
                                    let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
                                    let paymentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WDriverPaymentsVCID") as! WDriverPaymentsVC
                                    
                                    self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:"")
                                    drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
                                    drawerController.setDrawerState(.closed, animated: true)
                                }
                            })
                        }
                        else {
                            self.callAPIToCheckForVehicles()
                        }
                    }
                }
            }
        }
    }
    
    func callAPIToCheckForVehicles() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WDriverID] = userId
        
        let parentController = UIApplication.shared.keyWindow?.rootViewController
        
        let apiNameGetVehicle = kAPINameGetDriverVehicles(userId)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        AlertController.alert("Vehicle setup", message: "You must add at least one vehicle to your account before claiming a lesson. Add one now?",controller: parentController!, buttons: ["Not Now","Add Vehicle"], tapBlock: { (alertAction, position) -> Void in
                            if position == 1 {
                                let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
                                let vehiclesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WVehiclesVCID") as! WVehiclesVC
                                
                                self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg:"")
                                drawerController.mainViewController = UINavigationController(rootViewController : vehiclesVC)
                                drawerController.setDrawerState(.closed, animated: true)
                            }
                        })
                        
                    } else {
                        self.callAPIForClaimLessons()
                        
                    }
                    
                }
            }
            
        }
    }
    
    func callAPIToStartLesson() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        var apiNameStartLesson = ""
        
        if(self.isDriver) {
            paramDict[WDriverID] = userId
            apiNameStartLesson = kAPINameStartLessonDriver(lessonObj.lessonID, driverId: paramDict.value(forKey: WDriverID) as! String)
        }
        else {
            paramDict[WStudentID] = userId
            apiNameStartLesson = kAPINameStartLessonStudent(lessonObj.lessonID, studentId: paramDict.value(forKey: WStudentID) as! String)
        }
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameStartLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        self.customInit()
                    } else {
                        self.delegate?.removeViewWithLessonobj!(self.lessonObj, isEdit : false,msg : message)
                    }
                }
            }
        }
    }
    
    func callAPIToGetUserInfo(userId: String) {
        
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
                                AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction,         position) -> Void in
                                    if position == 0 {
                                        // do nothing
                                    }
                                })
                            } else {
                            self.driverInfo = WUserInfo.getUserInfo(responseObject!)
                                self.userNameLabel.text = self.driverInfo!.userFName
                                self.userPicImageView.setImageWithUrl(URL(string: self.driverInfo!.userImage)!, placeHolderImage: UIImage(named: "userPic"))
                                if(self.driverInfo!.isRegisteredDriver)
                                {
                                    self.hatImage.isHidden = false
                                } else {
                                    self.hatImage.isHidden = true
                                }
                                self.userTypeLabel.text = "Driver"
                                self.driverSelected = true
                        }
                    }
                }
            }
    }
    
    func getLessonCount() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WStudentID] = ""
        paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        var apiNameGetHistoryLesson = kAPINameGetHistoryInfo("",driverId:(UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetHistoryLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if (tempArray == nil || (tempArray?.count)! < 1)  {
                        self.isFirstLesson = true
                    }
                }
            }
        }
    }
}
