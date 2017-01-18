//
//  WLessonStartConfirmationVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-26.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WLessonStartConfirmationVC: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    
    var lessonObj = WLessonInfo()
    var isDriver = UserDefaults.standard.value(forKey: "wheelzIsDriver") as! Bool
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //addSubviewWithBounce(lessonView)
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
        if (self.isDriver) {
            self.headerLabel.text = "Your student wants to start the lesson."
        } else {
            self.headerLabel.text = "Your driver wants to start the lesson."
        }
    }
    
    @IBAction func confirmBtnAction(_ sender: Any) {
        callAPIToStartLesson()
    }

    @IBAction func startLaterBtnAction(_ sender: Any) {
        //send .PUT to set other party's claim to false
        self.removeFromSuperview()
    }
    

    // MARK - Web API methods
    
    func callAPIToStartLesson() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        var apiNameStartLesson = ""
        
        if(self.isDriver) == true {
            paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
            apiNameStartLesson = kAPINameStartLessonDriver(lessonObj.lessonID, driverId: paramDict.value(forKey: WDriverID) as! String)
        }
        else {
            paramDict[WStudentID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
            apiNameStartLesson = kAPINameStartLessonStudent(lessonObj.lessonID, studentId: paramDict.value(forKey: WStudentID) as! String)
        }
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameStartLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message == "OK" {
                        //TO DO: Redirect to lesson tracking view
                        DispatchQueue.main.async(execute: {
                        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
                        let lessonTrackingView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WLessonTrackingVCID") as! WLessonTrackingVC
                        lessonTrackingView.lessonObj = self.lessonObj
                            
                        drawerController.mainViewController = UINavigationController(rootViewController : lessonTrackingView)
                        drawerController.setDrawerState(.closed, animated: true)
                        self.removeFromSuperview()
                        })
                        
                        return
                    } else {
                        let message = responseObject?.object(forKey: "Message") as? String ?? ""
                        AlertController.alert("Uh-oh.", message: message)
                        self.removeFromSuperview()
                    }
                }
            }
            self.removeFromSuperview()
        }
    }

}
