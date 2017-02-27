//
//  WSelectSkillVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2017-02-06.
//  Copyright © 2017 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WSelectSkillVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var fareLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var requestLessonButton: WCustomButton!   
    var lessonObj : WLessonInfo!
    var regularDriverRate : Double = 0.0
    var instructorRate : Double = 0.0
    var shareRate : Double = 0.0
    var isFirstLesson: Bool = false
    var isEdit = false
    
    var labels = ["Manual", "Test", "Performance", "Turns", "Parking", "Highways"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        self.customInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        var cellIndex = 0
        
        if(self.isEdit)
        {
            switch lessonObj.lessonType
            {
            case 1:
                cellIndex = 0 // Parking
                break
            case 2:
                cellIndex = 1 // Test Prep
                break
            case 3:
                cellIndex = 2 // Turns
                break
            case 4:
                cellIndex = 3 // Manual
                break
            case 5:
                cellIndex = 4 // Highways
                break
            case 6:
                cellIndex = 5 // Performance
                break
            default:
                break
            }
            
            self.collectionView(self.collectionView, didSelectItemAt: IndexPath.init(item: cellIndex, section: 0))
            self.collectionView.selectItem(at: IndexPath.init(item: cellIndex, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition(rawValue: 0))
        }
    }

    //MARK:- Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:- Helper Methods
    func customInit() -> Void {
        self.navigationItem.title = "Skill Type"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
        if(self.isEdit) {
            self.requestLessonButton.setTitle("UPDATE LESSON", for: UIControlState.normal)
        }
        
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

    @IBAction func requestLessonBtnAction(_ sender: Any) {
        if(lessonObj.lessonType == 0)
        {
            presentFancyAlert("Whoops!", msgStr: "Please, select a skill.", type: AlertStyle.Info, controller: self)
        } else {
            if(isEdit) {
                callAPIForUpdateLessons()
            } else {
                callAPIForCreateNewLesson()
            }
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //addToList.append(objectsArray[indexPath.row])
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //addToList.append(objectsArray[indexPath.row])
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.backgroundColor = kAppOrangeColor.cgColor
        
        switch indexPath.item
        {
        case 0:
            self.lessonObj.lessonType = 1 // Parking
            break
        case 1:
            self.lessonObj.lessonType = 2 // Test Prep
            break
        case 2:
            self.lessonObj.lessonType = 3 // Turns
            break
        case 3:
            self.lessonObj.lessonType = 4 // Manual
            break
        case 4:
            self.lessonObj.lessonType = 5 // Highways
            break
        case 5:
            self.lessonObj.lessonType = 6 // Performance
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WheelzCell", for: indexPath as IndexPath) as! WLessonTypeCVCell
        var imageName = ""
        
        // Configure the cell
        switch indexPath.item
        {
            case 0:
                imageName = "lessonTypeParking"
                cell.descLbl.text = "Parking"
                break
            case 1:
                imageName = "lessonTypeTestPrep"
                cell.descLbl.text = "Test Prep"
                break
            case 2:
                imageName = "lessonTypeTurns"
                cell.descLbl.text = "Turns"
                break
            case 3:
                imageName = "lessonTypeManual"
                cell.descLbl.text = "Manual"
                break
            case 4:
                imageName = "lessonTypeHighway"
                cell.descLbl.text = "Highways"
                break
            case 5:
                imageName = "lessonTypePerformance"
                cell.descLbl.text = "Performance"
                break
            default:
                break
        }
        
        cell.image.image = UIImage(named: imageName)
        cell.layer.cornerRadius = 5
        
        return cell
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
        paramDict[WAmount] = lessonObj.lessonAmount
        paramDict[WType] = lessonObj.lessonType
        
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
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                    }
                }
            }
            
        }
    }
    
    fileprivate func callAPIForUpdateLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WDateTime] = String(format: "%@", Date(timeIntervalSince1970: lessonObj.lessonTimestamp) as CVarArg)
        paramDict[WLongitude] = lessonObj.locLon
        paramDict[WLatitude] = lessonObj.locLat
        paramDict[WDuration] = lessonObj.lessonDuration
        paramDict[WInstructorRequired] = lessonObj.isInstructorRequired
        paramDict[WUTCDateTime] = lessonObj.lessonTimestamp
        paramDict[WAmount] = lessonObj.lessonAmount
        paramDict[WType] = lessonObj.lessonType
        
        let apiNameUpdateLesson = kAPINameUpdateLesson()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUpdateLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("", message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil ) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                    } else {
                        //
                    }
                } else {
                    //
                }
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
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

extension WSelectSkillVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var collectionViewSize = collectionView.frame.size
        collectionViewSize.width = (collectionViewSize.width * 0.95) / 3.0 // Display 3 elements in a row
        collectionViewSize.height = (collectionViewSize.height * 1.2) / 3.0
        return collectionViewSize
    }
}
