//
//  AppDelegate.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
import AddressBookUI
import Stripe
import AirshipKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    enum environmentType {
        case development, production
    }
    
    let environment:environmentType = .development
    
    var window: UIWindow?
    var navController: UINavigationController?
    var locationManager: CLLocationManager!
    var currentAddress: String?
    var isFirstLoad : Bool = false
    
    var location = CLLocation()
    var sidePanel = KYDrawerController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Reachability.sharedManager!.startMonitoring()
        self.setUpDefaults()
        
        switch environment {
        case .development:
            // set web service URL to development
            apiUrl = "https://soireedev.azurewebsites.net"
            // set API keys to development
            STPPaymentConfiguration.shared().publishableKey = "pk_test_ARXZIzNBH3Q7rMoLTIpGlyzo"
            print("Development mode enabled.")
        case .production:
            // set web service URL to production
            apiUrl = "https://soireeprod.azurewebsites.net"
            // set API keys to production
            STPPaymentConfiguration.shared().publishableKey = "pk_live_JPABMHarWq47QctYseeITJnT"
            print("Production mode enabled.")
        }
        STPTheme.default().accentColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(85.0/255.0), blue: CGFloat(40.0/255.0), alpha: CGFloat(100.0))
        STPTheme.default().primaryBackgroundColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(250.0/255.0), blue: CGFloat(250.0/255.0), alpha: CGFloat(100.0))
        //STPPaymentConfiguration.sharedConfiguration().appleMerchantIdentifier = "apple merchant identifier" //to use Apple Pay
        
        UAirship.takeOff()
        UAirship.push().notificationOptions = [.alert, .badge, .sound]
        //UAirship.push().userPushNotificationsEnabled = true
        
        /*if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound]) {(accepted, error) in
                
                if !accepted {
                    print("Notification access denied")
                }
            }
        } else {
            // Fallback on earlier versions
        }*/
        
        return true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // remove mask when animation completes
        kAppDelegate.navController!.topViewController!.view.layer.mask = nil
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //SignalRManager.sharedInstance.manageConnection()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //SignalRManager.sharedInstance.manageConnection()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //Mark: Helper Methods
    func setUpDefaults(){
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.initializeNavigationBar()
        self.initLocationManager()
        self.isReachable()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "WLoginVCID") as! WLoginVC
        
        navController = UINavigationController(rootViewController: VC)
        navController!.navigationBar.isTranslucent = false

        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
    }
    
    func initializeNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(red: 64.0/255.0, green: 67.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().backgroundColor = UIColor(red: 64.0/255.0, green: 67.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : KAppHeaderFont]
    }
    
    func isReachable() -> Bool {
        return (Reachability.isConnectedToNetwork())
    }
    
    //MARK: Location Finder Methods
    func locationUpdate(_ location: CLLocation?) -> Void {
        if let location = location {
            logInfo("location   >>>   \(location)")
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        location = locationArray.lastObject as! CLLocation
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            self.getAddressFromLocation {
                (address:String?) in
                logInfo("\(address)")
                self.currentAddress = address
            }
        })
        if(CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateMap"), object: nil)
        } else if !self.isFirstLoad {
              NotificationCenter.default.post(name: Notification.Name(rawValue: "updateMap"), object: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        //print("locations error = \(error.localizedDescription)")
    }
    
    func addSidePanel() -> KYDrawerController  {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
        let sideMenuVC = storyBoard.instantiateViewController(withIdentifier: "WMenuVCID") as! WMenuVC
        sidePanel.mainViewController = UINavigationController(rootViewController : homeVC)
        sidePanel.drawerViewController = sideMenuVC
        
        return sidePanel
    }
    
    func getAddressFromLocation(_ completion:@escaping (String?) -> Void) {
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
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
                    completion ("\(self.location.coordinate.latitude), \(self.location.coordinate.longitude)")
                }
                
            } else {
                print("Problem with the data received from geocoder")
                return
            }
        })
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        //if notificationSettings.types != UIUserNotificationType() {
        //    application.registerForRemoteNotifications()
        //}
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        let userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? ""
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token:", tokenString)
        //print("Another Device Token:", UIDevice.current.identifierForVendor!.uuidString)
        
        if(!userId.isEmpty) {
            let paramDict = NSMutableDictionary()
            paramDict[WDeviceToken] = tokenString
            paramDict[WUserID] = userId
            
            let apiNameSaveDeviceToken = kAPINameSaveDeviceToken(userId, deviceToken: tokenString)
            
            ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameSaveDeviceToken, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
                
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
                            //nothing, really
                        }
                        
                    } else {
                        //uhhh
                    }
                }
            }
        } else {
            UserDefaults.standard.setValue(tokenString, forKey: "deviceToken")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if (application.applicationState == UIApplicationState.active)
        {
            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
            let lessonObj = WLessonInfo()
            let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
            let category = userInfo["category"] as? String ?? "OTHER"
            
            if category == "LESSON_START_CATEGORY" {
                lessonObj.lessonID = userInfo["lessonId"] as? String ?? ""
                lessonObj.studentStarted = (userInfo["studentStarted"] as? String ?? "").toBool()!
                lessonObj.driverStarted = (userInfo["driverStarted"] as? String ?? "").toBool()!
                
                if (lessonObj.studentStarted && lessonObj.driverStarted) {
                    //if started by both student and driver, redirect to Lesson Tracking
                    let lessonTrackingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLessonTrackingVCID") as! WLessonTrackingVC
                    lessonTrackingView.lessonObj = lessonObj
                    
                    drawerController.mainViewController = UINavigationController(rootViewController : lessonTrackingView)
                    drawerController.setDrawerState(.closed, animated: true)
                } else {
                    let confirmLessonView = Bundle.main.loadNibNamed("WLessonStartConfirmationVC", owner: nil, options: nil)?[0] as! WLessonStartConfirmationVC
                    confirmLessonView.lessonObj = lessonObj
                    confirmLessonView.customInit()
                    confirmLessonView.frame = (kAppDelegate.window?.bounds)!
                    //confirmLessonView.delegate = self
                    
                    kAppDelegate.window?.rootViewController!.view.addSubview(confirmLessonView)
                }
            }
            else if category == "LESSON_STOP_CATEGORY" {
                lessonObj.lessonID = userInfo["lessonId"] as? String ?? ""
                lessonObj.studentStarted = (userInfo["studentStarted"] as? String ?? "").toBool()!
                lessonObj.driverStarted = (userInfo["driverStarted"] as? String ?? "").toBool()!
                //redirect to Rate screen
                
                let rateLessonView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WRateLessonVCID") as! WRateLessonVC
                rateLessonView.lessonObj = lessonObj
                
                drawerController.mainViewController = UINavigationController(rootViewController : rateLessonView)
                drawerController.setDrawerState(.closed, animated: true)
            }
        }
       
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        //if (userInfo != nil) {
            //let message = userInfo.object(forKey: "Message") as? String ?? ""
            //if message != "" {
                //something went wrong, fail gracefully
            //} else {
              /*  let lessonObj = WLessonInfo()
                let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
                if identifier == "START_LESSON" {
                    lessonObj.lessonID = userInfo["lessonId"] as? String ?? ""
                    lessonObj.studentStarted = (userInfo["studentStarted"] as? String ?? "").toBool()!
                    lessonObj.driverStarted = (userInfo["driverStarted"] as? String ?? "").toBool()!
                    //let category = userInfo["category"] as? String ?? "OTHER"
                    
                    if (lessonObj.studentStarted && lessonObj.driverStarted) {
                        //if started by both student and driver, redirect to Lesson Tracking
                        let lessonTrackingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLessonTrackingVCID") as! WLessonTrackingVC
                        lessonTrackingView.lessonObj = lessonObj
                        
                        drawerController.mainViewController = UINavigationController(rootViewController : lessonTrackingView)
                        drawerController.setDrawerState(.closed, animated: true)
                    } else {
                        let confirmLessonView = Bundle.main.loadNibNamed("WLessonStartConfirmationVC", owner: nil, options: nil)?[0] as! WLessonStartConfirmationVC
                        confirmLessonView.lessonObj = lessonObj
                        confirmLessonView.customInit()
                        confirmLessonView.frame = (kAppDelegate.window?.bounds)!
                        //confirmLessonView.delegate = self
                        
                        kAppDelegate.window?.rootViewController!.view.addSubview(confirmLessonView)
                    }
                }
                else if identifier == "STOP_LESSON" {
                    lessonObj.lessonID = userInfo["lessonId"] as? String ?? ""
                    lessonObj.studentStarted = (userInfo["studentStarted"] as? String ?? "").toBool()!
                    lessonObj.driverStarted = (userInfo["driverStarted"] as? String ?? "").toBool()!
                    //let category = userInfo["category"] as? String ?? "OTHER"
                    //redirect to Rate screen
                    
                    let rateLessonView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WRateLessonVCID") as! WRateLessonVC
                    rateLessonView.lessonObj = lessonObj
                    
                    drawerController.mainViewController = UINavigationController(rootViewController : rateLessonView)
                    drawerController.setDrawerState(.closed, animated: true)
                }
            //}
        //}
        */
        completionHandler()
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
}

