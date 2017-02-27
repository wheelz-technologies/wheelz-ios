//
//  WMapViewController.swift
//  Wheelz
//
//  Created by Raj Kumar Sharma on 02/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import MapKit
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


class WMapViewController: UIViewController, MKMapViewDelegate, lessonDetailDelegate,lessonSelectDelegate {
    var SignUp = WSignUpStepOneVC()
    
    @IBOutlet weak var distanceSegment: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var requestLessionButton: UIButton!
    var latDelta:CLLocationDegrees = 0.50
    var longDelta:CLLocationDegrees = 0.50
    var lessonArray = NSMutableArray()
    var annotationTag : NSInteger = 0
    
    var lessonDetailView = WLessonDetailView()
    var calloutView = WCustomAnnotationView()
    var lessonInfo = NSMutableArray()
    
    var timer = Timer()
    var startTime = TimeInterval()
    var buttonTimer = Timer()
    var firstMapLoad = true
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
        
        // Scheduling timer to update map with the interval of 10 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(WMapViewController.scheduledUpdate), userInfo: nil, repeats: true)
        
        let aSelector : Selector = #selector(WMapViewController.updateButton)
        buttonTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    func scheduledUpdate() {
        if (self.isViewLoaded && self.view.window != nil && lessonDetailView.lessonID == nil) {
            callAPIForGetAvailableLessons()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if kAppDelegate.isFirstLoad {
             callAPIForGetAvailableLessons()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userLocationResetAction(UIButton())
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit  {
        NotificationCenter.default.removeObserver(self)
        timer.invalidate()
        buttonTimer.invalidate()
    }

    // MARK: - Private Methods
    fileprivate func customInit() {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = "Wheelz"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar",controller : self)
        self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("infoIcon",controller : self)
        distanceSegment.isHidden = SignUp.isDriving  ? false : true
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                presentFancyAlert("Location Services", msgStr: "Wheelz doesn't know where you are :( Please turn ON location in your Device Settings.", type: AlertStyle.Info, controller: self)
                break
            case .authorizedAlways, .authorizedWhenInUse:
                break
            }
        } else {
            print("Location services are not enabled")
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: "updateMap"),
            object: nil, queue: nil,
            using:{
                [weak self] note in
                self?.updateMapNotificationObserver()
                if(self?.firstMapLoad)! {
                    self?.userLocationResetAction(UIButton())
                    self?.firstMapLoad = false
                }
            })
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            requestLessionButton.isHidden = true
            
            for constraint in self.view.constraints as [NSLayoutConstraint] {
                if constraint.identifier == "mapViewBottomLayoutConstraint" {
                    constraint.constant = 20
                    self.view.layoutIfNeeded()
                    break
                    }
                }
        } else {
            requestLessionButton.isHidden = false
            let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(WMapViewController.requestLessonAtLocation(sender:)))
            uilgr.minimumPressDuration = 0.2
            mapView.addGestureRecognizer(uilgr)
        }
    }
    
    func requestLessonAtLocation(sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: mapView)

            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            
            let lessonLocation = Location(name: "", location: location,
                                          placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
            
            callAPIToRequestLesson(location: lessonLocation)
        }
    }
  
    func leftBarButtonAction(_ button : UIButton) {
        calloutView.removeFromSuperview()
        let drawerController = navigationController?.parent as! KYDrawerController
      drawerController.setDrawerState(.opened, animated: true)
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        let tipVc = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            tipVc.orderedViewControllers = [newViewControllerFromMain(name: "WMapTipVCID"),
                                            newViewControllerFromMain(name: "WLessonTypesVCID"),
                                            newViewControllerFromMain(name: "WDriverSignUpTip1VCID"),
                                            newViewControllerFromMain(name: "WDriverSignUpTip2VCID"),
                                            newViewControllerFromMain(name: "WDriverSignUpTip3VCID"),
                                            newViewControllerFromMain(name: "WDriverLessonTip2VCID"),
                                            newViewControllerFromMain(name: "WStartLessonTipVCID"),
                                            newViewControllerFromMain(name: "WTrackingLessonTipVCID"),
                                            newViewControllerFromMain(name: "WRateLessonTipVCID")]
        } else {
            tipVc.orderedViewControllers = [newViewControllerFromMain(name: "WMapTipVCID"),
                                            newViewControllerFromMain(name: "WLessonTypesVCID"),
                                            newViewControllerFromMain(name: "WStudentSignUpTip1VCID"),
                                            newViewControllerFromMain(name: "WStudentSignUpTip2VCID"),
                                            newViewControllerFromMain(name: "WStudentSignUpTip3VCID"),
                                            newViewControllerFromMain(name: "WStartLessonTipVCID"),
                                            newViewControllerFromMain(name: "WTrackingLessonTipVCID"),
                                            newViewControllerFromMain(name: "WRateLessonTipVCID")]
        }
        
        kAppDelegate.window?.rootViewController!.present(tipVc, animated: true, completion: nil)
    }
    
    func updateMapNotificationObserver()  {
        if !kAppDelegate.isFirstLoad {
            self.callAPIForGetAvailableLessons()
        }
    }
    
    func updateButton() {
        let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.03, y: 1.03);
        
        self.requestLessionButton.transform = expandTransform
        UIView.animate(withDuration: 2.0,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.requestLessionButton.transform = expandTransform.inverted()
        }, completion: {
            //Code to run after animating
            (value: Bool) in
            return
        })
    }
    
    @IBAction func userLocationResetAction(_ sender: Any) {
        let newCamera = MKMapCamera()
        newCamera.centerCoordinate = self.mapView.camera.centerCoordinate;
        newCamera.heading = self.mapView.camera.heading;
        newCamera.altitude = self.mapView.camera.altitude;
        self.mapView.setCamera(newCamera, animated: true)
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(kAppDelegate.location.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func setUpOnLoad()  {
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove)
        mapView.showsUserLocation = true
        
        for case let lessonObj as WLessonInfo in lessonArray {
            let loc = CLLocation(latitude: lessonObj.locLat, longitude: lessonObj.locLon)
            let lessonPosition = WCustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
//            lessonPosition.coordinate = loc.coordinate
            lessonPosition.title = getDateFromTimeStamp(lessonObj.lessonTimestamp) 
            lessonPosition.subtitle = getTimeFromTimeStamp(lessonObj.lessonTimestamp) 
            lessonPosition.lessonID = lessonObj.lessonID
            lessonPosition.driverID = lessonObj.driverID
            lessonPosition.studentID = lessonObj.studentID
            lessonPosition.type = lessonObj.lessonType
            lessonPosition.isConfirmed = lessonObj.isConfirmed
            lessonPosition.isInstructorRequired = lessonObj.isInstructorRequired
            mapView.addAnnotation(lessonPosition)
        }
    }
    
    func getDateFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func getTimeFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }

    // MARK: - UIButton Action Methods
    @IBAction func onRequestLession(_ sender: AnyObject) {
        //check if student has payment profiles, otherwise requesting lessons is not allowed
        callAPIToRequestLesson(location: nil)
    }
    
    @IBAction func onDistanceSegment(_ sender: AnyObject) {
    }
    
    //MARK:- MapView Delegates
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation
        {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = determineMapMarkerType(marker: (annotation as! WCustomAnnotation))
        
        /*if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            
            //if lesson is claimed by the active user (driver), show green icon
            if((annotation as! WCustomAnnotation).driverID == (UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? "")) {
                annotationView?.image = resizeImage(imageName: "wheelzGreen", width: 66, height: 66)
            } else
            //if instructor is required, show blue icon, else show orange
            if ((annotation as! WCustomAnnotation).isInstructorRequired) {
                annotationView?.image = resizeImage(imageName: "wheelzBlue", width: 55, height: 55)
            }
        } else {
                //if the lesson does not belong to the user, show gray icon
            if ((annotation as! WCustomAnnotation).studentID != (UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? "")) {
                annotationView?.image = resizeImage(imageName: "wheelzGray", width: 48, height: 48)
            } //if lesson is claimed, show blue icon, else show orange
            else if (!(annotation as! WCustomAnnotation).driverID.isEmpty) {
                annotationView?.image = resizeImage(imageName: "wheelzBlue", width: 55, height: 55)
            }
        } */
        annotationView?.cornerRadius = (annotationView?.frame.size.width)!/2
        
        let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.1, y: 1.1);
        
        annotationView?.transform = expandTransform
        UIView.animate(withDuration: 0.4,
                       delay:0.0,
                       options: .curveEaseIn,
                       animations: {
                        annotationView?.transform = expandTransform.inverted()
        }, completion: {
            //Code to run after animating
            (value: Bool) in
            return
        })
        
        annotationView?.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        annotationView?.layer.bounds.offsetBy(dx: 16.0, dy: 16.0)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! WCustomAnnotation
        let tempLocArray = NSMutableArray()
        
        for case let lessonObj as WLessonInfo in lessonArray {

            if customAnnotation.coordinate.latitude  == lessonObj.locLat && customAnnotation.coordinate.longitude == lessonObj.locLon{
                tempLocArray.add(lessonObj)
            }
        }
        
        if (customAnnotation.studentID != (UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? "") && (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) != true)
        {
            return;
        }

        if tempLocArray.count > 1 {
            let views = Bundle.main.loadNibNamed("WCustomAnnotationView", owner: nil, options: nil)
            calloutView = views?[0] as! WCustomAnnotationView
            calloutView.locationArray = tempLocArray
            calloutView.center = CGPoint(x: (kAppDelegate.window?.rootViewController!.view.bounds.size.width)! / 2, y: (kAppDelegate.window?.rootViewController!.view.bounds.size.height)!*0.54)
            calloutView.selectDelegate = self
            calloutView.backgroundColor = UIColor.clear
//            view.addSubview(calloutView)
            kAppDelegate.window?.addSubview(calloutView)
           
        } else {
            lessonDetailView = Bundle.main.loadNibNamed("WLessonDetailView", owner: nil, options: nil)?[0] as! WLessonDetailView

            lessonDetailView.lessonID = customAnnotation.lessonID
            lessonDetailView.customInit()
            lessonDetailView.frame = (kAppDelegate.window?.bounds)!
            lessonDetailView.delegate = self
            kAppDelegate.window?.rootViewController!.view.addSubview(lessonDetailView)
        }
    }
  
     func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        calloutView.removeFromSuperview()
    }
    
    //MARK:- Lesson Detail Delegate Methods
    func removeViewWithLessonobj(_ lessonObj: WLessonInfo, isEdit : Bool,msg:String)  {
        lessonDetailView.removeFromSuperview()
        lessonDetailView.updateTimer?.invalidate()
        lessonDetailView.updateTimer = nil
        lessonDetailView.lessonObj = WLessonInfo()
        lessonDetailView.lessonID = nil
        NotificationCenter.default.removeObserver(lessonDetailView)
        
        if isEdit {
            self.calloutView.removeFromSuperview()
            let editLessonVC = self.storyboard?.instantiateViewController(withIdentifier: "WSelectDateVCID")as! WSelectDateVC
            editLessonVC.lessonInfo = lessonObj
            editLessonVC.isEdit = true
            
            self.navigationController?.pushViewController(editLessonVC, animated: true)
        } else if msg != "" {
            delay(1.0, closure: {
                 AlertController.alert("", message: msg)
            })
        } else {
            scheduledUpdate()
        }
    }
    
    //MARK:- Lesson Detail Delegate Methods
    func selectLessonId(_ lessonId: String, view : UIView) {
        calloutView.removeFromSuperview()
        lessonDetailView = Bundle.main.loadNibNamed("WLessonDetailView", owner: nil, options: nil)?[0] as! WLessonDetailView
        lessonDetailView.lessonID = lessonId
        lessonDetailView.customInit()
        lessonDetailView.frame = (kAppDelegate.window?.bounds)!
        lessonDetailView.delegate = self
        
        kAppDelegate.window?.rootViewController!.view.addSubview(lessonDetailView)
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForGetAvailableLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict["latitude"] = kAppDelegate.location.coordinate.latitude
        paramDict["longitude"] = kAppDelegate.location.coordinate.longitude
        
        let userID = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        var apiNameGetAvailableResources  = String()
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            apiNameGetAvailableResources = kAPINameGetAvailableDriverLessons(userID!, isInstructor: (UserDefaults.standard.value(forKey: "wheelzIsInstructor") as? Bool)!, latitude: kAppDelegate.location.coordinate.latitude, longitude: kAppDelegate.location.coordinate.longitude)
            paramDict[WDriverID] = userID
            paramDict[WUserInstructor] = (UserDefaults.standard.value(forKey: "wheelzIsInstructor") as? Bool)!
        } else {
                apiNameGetAvailableResources = kAPINameGetAvailableStudentLessons(userID!, latitude: kAppDelegate.location.coordinate.latitude, longitude: kAppDelegate.location.coordinate.longitude)
        }
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetAvailableResources, hudType: .smoothProgress) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                //AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    kAppDelegate.isFirstLoad = true
                        self.lessonArray = WLessonInfo.getAvailableLessonInfo(responseObject! as! NSMutableArray)
                    
                        self.mapView.delegate = self
                        self.setUpOnLoad()
                }
            }
            
        }
    }
    
    //MARK:- Web API Section
    func callAPIToRequestLesson(location: Location?) {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetCards = kAPINameGetAllCards(paramDict.value(forKey: WUserID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetCards, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        AlertController.alert("Payment method", message: "It looks like you haven't added any payment methods yet. Add one now?",controller: self, buttons: ["Not Now","Add Card"], tapBlock: { (alertAction, position) -> Void in
                            if position == 1 {
                                let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
                                let paymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WPaymentsVCID") as! WPaymentsVC
                                
                                drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
                                drawerController.setDrawerState(.closed, animated: true)
                            }
                        })
                    } else {
                        self.calloutView.removeFromSuperview()
                        let selectDateVC = self.storyboard?.instantiateViewController(withIdentifier: "WSelectDateVCID")as! WSelectDateVC
                        
                        if(location != nil) {
                            selectDateVC.location = location
                        }
                        
                        self.navigationController?.pushViewController(selectDateVC, animated: true)
                    }
                    
                }
            }
        }
    }
    
}
