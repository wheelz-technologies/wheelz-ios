//
//  WLessonTrackingVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-26.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import MapKit

class WLessonTrackingVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lessonTimeLabel: UILabel!
    
    var latDelta:CLLocationDegrees = 0.50
    var longDelta:CLLocationDegrees = 0.50
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    
    var regularDriverRate : Double = 0.0
    var instructorRate : Double = 0.0
    
    var lessonObj = WLessonInfo()
    var startTime = TimeInterval()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let aSelector : Selector = #selector(WLessonTrackingVC.updateTime)
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(kAppDelegate.location.coordinate, span)
        mapView.setRegion(region, animated: true)
        let newCamera = MKMapCamera()
        newCamera.centerCoordinate = self.mapView.camera.centerCoordinate;
        newCamera.heading = self.mapView.camera.heading;
        newCamera.altitude = self.mapView.camera.altitude;
        let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove)
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        mapView.showsUserLocation = true
        
        self.navigationItem.title = "Lesson Progress"
        
        let button:UIButton = UIButton.init(type: UIButtonType.custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: "backArrow" as String), for: UIControlState())
        button.addTarget(self, action: #selector(backBarBackButtonAction(_:)), for: UIControlEvents.touchUpInside)
        button.addTarget(self, action: #selector(WLessonTrackingVC.backHome), for: UIControlEvents.touchUpInside)
        let leftBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: button)
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        callAPIForGetRates()
    }
    
    @objc func applicationDidBecomeActive() {
        //check if lesson had finished
        callAPIForGetLessons(lessonObj.lessonID)
    }
    
    func backHome(sender: AnyObject) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        drawerController.setDrawerState(.closed, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopLessonBtnAction(_ sender: Any) {
        AlertController.alert("Finish Lesson", message: "Stop this lesson?",controller: (self), buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
            if position == 1 {
                self.callAPIToFinishLesson()
            }
        })
    }
    
    // MARK : Custom Methods
    func updateTime() {
        
        let calendar = NSCalendar.current as NSCalendar
        
        // Replace the hour (time) of both dates with 00:00
        let lessonStartTime = Date(timeIntervalSince1970: lessonObj.lessonTimestamp)
        
        let flags = NSCalendar.Unit.second
        let components = calendar.components(flags, from: lessonStartTime, to: Date(), options: [])
        
        let hoursDiff = (Double(components.second!) / Double(3600))
        
        //figure out if we need instructor or regular rates
        if(lessonObj.isInstructorRequired) {
            lessonTimeLabel.text = String(format:"$%.0f",hoursDiff *  instructorRate)
        } else {
            lessonTimeLabel.text = String(format:"$%.0f",hoursDiff *  regularDriverRate)
        }
        //apply rates
        
        /*var currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        //let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        //let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        
        lessonTimeLabel.text = "\(strMinutes):\(strSeconds)"*/
    }
    
    // MARK : Web API Methods
    func callAPIToFinishLesson() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WLessonID] = lessonObj.lessonID
        
        let apiNameFinishLesson = kAPINameFinishLesson(lessonObj.lessonID, userId: paramDict.value(forKey: WUserID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameFinishLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("Whoops!",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        //Redirect to "Rate" screen
                        self.redirectToRateView()
                    } else {
                        let message = responseObject?.object(forKey: "Message") as? String ?? ""
                        AlertController.alert("Whoops!", message: message)
                    }
                }
            }
        }
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
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        AlertController.alert("Whoops!",message: (error?.localizedDescription)!)
                    } else {
                        self.lessonObj = WLessonInfo.getLessonInfo(responseObject! as! NSMutableDictionary)
                        
                        if(self.lessonObj.finished) {
                            self.redirectToRateView()
                        }
                    }
                }
            }
            
        }
    }
    
    fileprivate func callAPIForGetRates() {
        
        let paramDict = NSMutableDictionary()
        let apiNameGetRates = kAPINameGetRates()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetRates, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message == "" {
                        self.regularDriverRate = responseObject?.object(forKey: "regularDriver") as? Double ?? 0.0
                        self.instructorRate =  responseObject?.object(forKey: "instructor") as? Double ?? 0.0
                    } else  {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    }
                }
            }
            
        }
    }
    
    func redirectToRateView() {
        DispatchQueue.main.async(execute: {
            let rateLessonView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WRateLessonVCID") as! WRateLessonVC
            rateLessonView.lessonObj = self.lessonObj
        
            self.navigationController?.pushViewController(rateLessonView, animated: true)
        })
    }

    // MKMapView and CLLocationManager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocations.append(locations[0])
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
        if (myLocations.count > 1) {
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            mapView.add(polyline)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(85.0/255.0), blue: CGFloat(40.0/255.0), alpha: CGFloat(100.0))
            polylineRenderer.lineWidth = 6
            
            return polylineRenderer
        }
        return MKPolylineRenderer()
    }
}
