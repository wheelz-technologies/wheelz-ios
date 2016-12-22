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
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
        scheduledTimerWithTimeInterval()
        
        let aSelector : Selector = #selector(WMapViewController.updateButton)
        buttonTimer = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(WMapViewController.scheduledUpdate), userInfo: nil, repeats: true)
    }
    
    func scheduledUpdate() {
        if (self.isViewLoaded && self.view.window != nil){
            callAPIForGetAvailableLessons()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        if kAppDelegate.isFirstLoad {
             callAPIForGetAvailableLessons()
        }
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit  {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Methods
    fileprivate func customInit() {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.navigationController?.isNavigationBarHidden = true
        self.navigationItem.title = "Wheelz"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar",controller : self)
                 distanceSegment.isHidden = SignUp.isDriving  ? false : true
//                    self.view.layoutSubviews()
//                    self.view.layoutIfNeeded()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                AlertController.alert("",message: "Please turn ON location in your Device Settings.")
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
            })
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            requestLessionButton.isHidden = true
            
            for constraint in self.view.constraints as [NSLayoutConstraint] {
                if constraint.identifier == "mapViewBottomLayoutConstraint" {
                    constraint.constant = 0
                    self.view.layoutIfNeeded()
                    break
                    }
                }
        } else {
            requestLessionButton.isHidden = false
            let uilgr = UILongPressGestureRecognizer(target: self, action: #selector(WMapViewController.requestLessonAtLocation(sender:)))
            uilgr.minimumPressDuration = 2.0
            mapView.addGestureRecognizer(uilgr)
        }
    }
    
    func requestLessonAtLocation(sender:UILongPressGestureRecognizer) {
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
    
    func setUpOnLoad()  {
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(kAppDelegate.location.coordinate, span)
//        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
        let newCamera = MKMapCamera()
        newCamera.centerCoordinate = self.mapView.camera.centerCoordinate;
        newCamera.heading = self.mapView.camera.heading;
        newCamera.altitude = self.mapView.camera.altitude;
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove)
        mapView.showsUserLocation = true
//        self.mapView.setCamera(newCamera, animated: true)
        
        for case let lessonObj as WLessonInfo in lessonArray {
            let loc = CLLocation(latitude: lessonObj.locLat, longitude: lessonObj.locLon)
            let lessonPosition = WCustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
//            lessonPosition.coordinate = loc.coordinate
            lessonPosition.title = getDateFromTimeStamp(lessonObj.lessonTimestamp) 
            lessonPosition.subtitle = getTimeFromTimeStamp(lessonObj.lessonTimestamp) 
            lessonPosition.lessonID = lessonObj.lessonID
            lessonPosition.driverID = lessonObj.driverID
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
    
    @IBAction func infoButtonAction(_ sender: Any) {
        let mapTipVc = self.storyboard?.instantiateViewController(withIdentifier: "WMapTipVCID") as! WMapTipVC
        mapTipVc.modalPresentationStyle = .overCurrentContext
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            mapTipVc.isDriver = true
           //presentFancyAlert("Hi!", msgStr: "It's simple - tap the lesson icon on the map, claim it and then just show up on time ;)", type: AlertStyle.Info, controller: self)
        } else {
            //presentFancyAlert("Hi!", msgStr: "Tap the wheel icon on the bottom of the screen to request a lesson, fill out the details and let us find you a perfect instructor.\n\n" + "We'll let you know right away!", type: AlertStyle.Info, controller: self)
            mapTipVc.isDriver = false
        }
        kAppDelegate.window?.rootViewController!.present(mapTipVc, animated: true, completion: nil)
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
        }else{
            annotationView?.annotation = annotation
        }
        
        annotationView?.image = resizeImage(imageName: "wheelzOrange", width: 30, height: 30)
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            
            //if lesson is claimed by the active user (driver), show green icon
            if((annotation as! WCustomAnnotation).driverID == (UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? "")) {
                annotationView?.image = resizeImage(imageName: "wheelzGreen", width: 40, height: 40)
            } else
            //if instructor is required, show blue icon, else show orange
            if ((annotation as! WCustomAnnotation).isInstructorRequired) {
                annotationView?.image = resizeImage(imageName: "wheelzBlue", width: 35, height: 35)
            }
        } else {
            //if lesson is claimed, show blue icon, else show orange
            if (!(annotation as! WCustomAnnotation).driverID.isEmpty) {
                annotationView?.image = resizeImage(imageName: "wheelzBlue", width: 35, height: 35)
            }
        }
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
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is MKUserLocation {
            return
        }
        let customAnnotation = view.annotation as! WCustomAnnotation
        let tempLocArray = NSMutableArray()
        print(customAnnotation.coordinate.latitude,"==",customAnnotation.coordinate.longitude)
          for case let lessonObj as WLessonInfo in lessonArray {

            if customAnnotation.coordinate.latitude  == lessonObj.locLat && customAnnotation.coordinate.longitude == lessonObj.locLon{
                tempLocArray.add(lessonObj)
            }
        }

        if  tempLocArray.count > 1{
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
        if isEdit {
            let editLessonVC = self.storyboard?.instantiateViewController(withIdentifier: "WEditLessonVCID") as! WEditLessonVC
            editLessonVC.lessonObj = lessonObj
            self.present(UINavigationController(rootViewController : editLessonVC) , animated: true, completion: {
                //
                }
            )
//            self.navigationController?.pushViewController(editLessonVC, animated: true)
        } else if msg != "" {
            delay(1.0, closure: { 
                 AlertController.alert("", message: msg)
            })
        } else {
            self.callAPIForGetAvailableLessons()
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
        let userID = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        var apiNameGetAvailableResources  = String()
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            apiNameGetAvailableResources = kAPINameGetAvailableDriverLessons(userID!, isInstructor: (UserDefaults.standard.value(forKey: "wheelzIsInstructor") as? Bool)!, lattitude: kAppDelegate.location.coordinate.latitude, longitude: kAppDelegate.location.coordinate.longitude)
            paramDict[WDriverID] = userID
            paramDict[WUserInstructor] = (UserDefaults.standard.value(forKey: "wheelzIsInstructor") as? Bool)!
            paramDict["latitude"] = kAppDelegate.location.coordinate.latitude
            paramDict["longitude"] = kAppDelegate.location.coordinate.longitude
        } else {
                apiNameGetAvailableResources = kAPINameGetAvailableStudentLessons(userID!)
        }
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetAvailableResources, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
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
