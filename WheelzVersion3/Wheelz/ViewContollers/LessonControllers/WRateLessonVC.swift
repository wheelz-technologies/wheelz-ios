//
//  WRateLessonVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-11-05.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WRateLessonVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var yourPayLabel: UILabel!
    @IBOutlet weak var reviewTextField: UITextView!
    
    var regularDriverRate : Double = 0.0
    var instructorRate : Double = 0.0
    var share : Double = 0.0
    
    var lessonObj : WLessonInfo!
    var rating = 3;
    var reviewText = ""
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
        callAPIForGetRates()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(WRateLessonVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        reviewTextField.delegate = self
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func rateValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            reviewTextField.text = "[Tap to edit] I faced major issues during the lesson.";
            self.rating = 1
            break
        case 1:
            reviewTextField.text = "[Tap to edit] The overall experience was pretty bad.";
            self.rating = 2
            break
        case 2:
            reviewTextField.text = "[Tap to edit] Lesson wasn't outstanding, but I didn't have any major issues.";
            self.rating = 3
            break
        case 3:
            reviewTextField.text = "[Tap to edit] I've had a great time and haven't had any issues at all.";
            self.rating = 4
            break
        default:
            reviewTextField.text = "[Tap to edit] The lesson was absolutely perfect!";
            self.rating = 5
            break;
        }
        
        reviewTextField.textColor = UIColor.lightGray
        reviewTextField.endEditing(true)
        self.reviewText = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars <= 140;
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        reviewTextField.textColor = UIColor.white
        reviewTextField.text = ""
        self.reviewText = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.reviewText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    @IBAction func submitButtonClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        callAPIForRateLesson()
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForRateLesson() {
        
        let userId = isDriver ? self.lessonObj.studentID : self.lessonObj.driverID
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = userId
        paramDict[WRating] = String(self.rating)
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WText] = self.reviewText.trimWhiteSpace()
        
        //let apiRateLesson = kAPINameRateLesson(paramDict.value(forKey: WUserID) as! String, rating: paramDict.value(forKey: WRating) as! String, lessonId: paramDict.value(forKey: WLessonID) as! String)
        let apiRateLesson = kAPINameRateLesson()
        
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
                        
                        if(self.isDriver) {
                            //calculate the pay
                            let wheelzShare : Double = self.lessonObj.lessonAmount * (self.share / 100)
                            self.yourPayLabel.text = String(format: "your pay: $%.2f", self.lessonObj.lessonAmount - wheelzShare)
                            self.yourPayLabel.isHidden = false
                        } else {
                            if(!self.lessonObj.promoCodeID.isEmpty) {
                                let apiNameGetPromoCode = kAPINameGetPromoCodeById(self.lessonObj.promoCodeID)
                                
                                ServiceHelper.sharedInstance.callAPIWithParameters(NSMutableDictionary(), method: .get, apiName: apiNameGetPromoCode, hudType: .noProgress) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
                                    
                                    if error != nil {
                                        return
                                    } else {
                                        if (responseObject != nil) {
                                            // apply promo code to lesson and proceed
                                            let discount = responseObject!.object(forKey: "discount") as? Double ?? 0
                                            let discountAmount : Double = self.lessonObj.lessonAmount * discount / 100.0
                                            self.totalPriceLabel.text = String(format:"$%.0f", self.lessonObj.lessonAmount - discountAmount)
                                        }
                                    }
                                }
                            }
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
                    self.regularDriverRate = responseObject?.object(forKey: "regularDriver") as? Double ?? 30.0
                    self.instructorRate =  responseObject?.object(forKey: "instructor") as? Double ?? 40.0
                    self.share = responseObject?.object(forKey: "share") as? Double ?? 19.0
                }
            }
            
            self.callAPIForGetLessons(self.lessonObj.lessonID)
        }
    }
}
