//
//  WNeedInstructorVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 07/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WNeedInstructorVC: UIViewController {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var fareLabel: UILabel!
    var lessonObj : WLessonInfo!
    var regularDriverRate : Double = 0.0
    var instructorRate : Double = 0.0
    var shareRate : Double = 0.0
    var isFirstLesson: Bool = false
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customInit()
    }
    
    //MARK:- Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Helper Methods
    func customInit() -> Void {
        self.navigationItem.title = "Certified Instructor"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        print(lessonObj.lessonDuration)
        callAPIForGetRates()
        getLessonCount()
    }
    
    func setFareAmount() {
        if lessonObj.isInstructorRequired {
            fareLabel.text = String(format:"$%.0f",lessonObj.lessonDuration *  instructorRate)
            lessonObj.lessonAmount = lessonObj.lessonDuration * instructorRate
        } else {
            fareLabel.text = String(format:"$%.0f",lessonObj.lessonDuration *  regularDriverRate)
             lessonObj.lessonAmount = lessonObj.lessonDuration * regularDriverRate
        }
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func yesButtonAction(_ sender: UIButton) {
        yesButton.isSelected = true
        noButton.isSelected = false
        lessonObj.isInstructorRequired = true
        setFareAmount()
        
        animateImageBounce(imageView: sender.imageView!)
    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {
        yesButton.isSelected = false
        noButton.isSelected = true
        lessonObj.isInstructorRequired = false
        setFareAmount()
        
        animateImageBounce(imageView: sender.imageView!)
    }
    
    @IBAction func requestLessonButtonAction(_ sender: UIButton) {
        callAPIForCreateNewLesson()
    }
    
    //MARK:- Web API Section
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
                        self.shareRate =  responseObject?.object(forKey: "share") as? Double ?? 0.0
                        self.setFareAmount()
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
    
    fileprivate func callAPIForCreateNewLesson() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WStudentID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WDateTime] = ""
        paramDict[WLongitude] = lessonObj.locLon
        paramDict[WLatitude] = lessonObj.locLat
        paramDict[WDuration] = lessonObj.lessonDuration
        paramDict[WInstructorRequired] = lessonObj.isInstructorRequired
        paramDict[WUTCDateTime] = lessonObj.lessonTimestamp
        paramDict[WAmount] =   lessonObj.lessonAmount
        let apiNameCreateNewLesson = kAPINameCreateLesson()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameCreateNewLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "Created" {
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        if(self.isFirstLesson)
                        {
                            let firstLessonTipVc = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                            firstLessonTipVc.orderedViewControllers = [newViewControllerFromMain(name: "WStudentLessonTip1VCID"),
                                                                       newViewControllerFromMain(name: "WStartLessonTipVCID"),
                                                                       newViewControllerFromMain(name: "WTrackingLessonTipVCID"),
                                                                       newViewControllerFromMain(name: "WRateLessonTipVCID")]
                            
                            kAppDelegate.window?.rootViewController!.present(firstLessonTipVc, animated: true, completion: nil)
                        } else {
                            let lessonTipVc = self.storyboard?.instantiateViewController(withIdentifier: "WLessonTipVCID") as! WLessonTipVC
                            lessonTipVc.modalPresentationStyle = .overCurrentContext
                        
                            kAppDelegate.window?.rootViewController!.present(lessonTipVc, animated: true, completion: nil)
                        }
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
    
    func getLessonCount() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WStudentID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WDriverID] = ""
        var apiNameGetHistoryLesson = kAPINameGetHistoryInfo((UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!,driverId:"")
        
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
