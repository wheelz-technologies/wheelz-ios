//
//  WRateLessonVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-05.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WRateLessonVC: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var lessonObj : WLessonInfo!
    var rating = 3;
    var isDriver = UserDefaults.standard.value(forKey: "wheelzIsDriver") as! Bool
    
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
        self.navigationItem.title = "Rate Lesson"
        callAPIForGetLessons(lessonObj.lessonID)
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func rateValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            descriptionLabel.text = "I faced major issues during the lesson.";
            self.rating = 1
            break
        case 1:
            descriptionLabel.text = "The overall experience was pretty bad.";
            self.rating = 2
            break
        case 2:
            descriptionLabel.text = "Lesson wasn't outstanding, but I didn't have any major issues.";
            self.rating = 3
            break
        case 3:
            descriptionLabel.text = "I've had a great time and haven't had any issues at all.";
            self.rating = 4
            break
        default:
            descriptionLabel.text = "The lesson was absolutely perfect!";
            self.rating = 5
            break;
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: AnyObject) {
        callAPIForRateLesson()
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForRateLesson() {
        
        let userId = isDriver ? self.lessonObj.studentID : self.lessonObj.driverID
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = userId
        paramDict[WRating] = String(self.rating)
        paramDict[WLessonID] = lessonObj.lessonID
        
        let apiRateLesson = kAPINameRateLesson(paramDict.value(forKey: WUserID) as! String, rating: paramDict.value(forKey: WRating) as! String, lessonId: paramDict.value(forKey: WLessonID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiRateLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                       DispatchQueue.main.async(execute: {
                        let thankYouView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WThankYouVCID") as! WThankYouVC
                        
                        self.navigationController?.pushViewController(thankYouView, animated: true)
                       })
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
                        
                        self.totalPriceLabel.text = String(format: "$%.2f", self.lessonObj.lessonAmount)
                    }
                }
            }
            
        }
    }
}
