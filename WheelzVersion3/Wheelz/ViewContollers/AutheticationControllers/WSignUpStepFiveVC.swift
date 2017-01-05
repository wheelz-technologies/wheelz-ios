//
//  WSignUpStepFiveVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation

class WSignUpStepFiveVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var tappableLabel: UITextView!
    
    @IBOutlet weak var skipStepButton: WCustomButton!
    
    @IBOutlet weak var topContinueConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressStepFiveView: UIProgressView!
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    var stepFiveObj : WUserInfo!
    var imageData : Data!
    var imageUploaded = false;
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getCountryAndCityForUser(kAppDelegate.location.coordinate.latitude, lon: kAppDelegate.location.coordinate.longitude)
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height/2
        profileImageButton.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        progressStepFiveView.setProgress(1.0, animated: true)
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributedText = NSMutableAttributedString(string: "By creating an account you agree to the Terms of Use and you acknowledge that you have read the Privacy Policy",attributes: [NSForegroundColorAttributeName : KAppPlaceholderColor,NSFontAttributeName:UIFont(name:"HelveticaNeue-Light", size:9)!,NSParagraphStyleAttributeName:style])
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.styleSingle.rawValue, range: (attributedText.string as NSString).range(of: "Terms of Use"))
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.styleSingle.rawValue, range: (attributedText.string as NSString).range(of: "Privacy Policy"))
        attributedText.addAttribute(NSLinkAttributeName, value: "http://www.learnwheelz.com/privacy-policy", range: (attributedText.string as NSString).range(of: "Privacy Policy"))
                attributedText.addAttribute(NSLinkAttributeName, value: "http://www.learnwheelz.com/terms-of-use", range: (attributedText.string as NSString).range(of: "Terms of Use"))
        tappableLabel.attributedText = attributedText 
    }
    
    fileprivate func getCountryAndCityForUser(_ lat : CLLocationDegrees, lon : CLLocationDegrees) {
        let location = CLLocation(latitude: lat, longitude: lon) //changed!!!
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                print(pm.country)
                if (pm.country != nil) {
                    self.stepFiveObj.userCountry = pm.country!
                    self.stepFiveObj.userCity = pm.locality!
                    print(pm.locality)
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    // MARK: UIButton Action Methods
    @IBAction func skipButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.callAPIForSignUp(!imageUploaded) //if image is NOT uploaded, skip parameter = true
    }
    
    @IBAction func profileImgBtnAction(_ sender: UIButton) {
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        
//>>>>>>>>>>>>>>>>>>>>> Dead code; As project is for iPhone only, so else part will never execute
        // Present the actionsheet
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(alert, animated: true, completion: nil)
        } else {
            popover=UIPopoverController(contentViewController: alert)
            popover!.present(from: profileImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker?.delegate = self
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker?.navigationBar.tintColor = UIColor.white
            self .present(picker!, animated: true, completion: nil)
        } else {
            openGallery()
        }
    }
    
    func openGallery() {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker?.delegate = self
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(picker!, animated: true, completion: nil)
            picker?.navigationBar.tintColor = UIColor.white
        } else {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.present(from: profileImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: {
            self.profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            UIView.animate(withDuration: 4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 7.0, options: UIViewAnimationOptions(), animations: ({
                self.skipStepButton.setTitle("Continue", for: UIControlState.normal)
                self.imageUploaded = true;
                self.view.layoutSubviews()
            }), completion: nil)
        })
            self.imageData = Data()
            self.imageData = UIImageJPEGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage!)!,0.2)!
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForSignUp(_ skip : Bool) {
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserName] = stepFiveObj.userName
        paramDict[WUserPassword] = stepFiveObj.userPasswordHash
        paramDict[WUserFName] = stepFiveObj.userFName
        paramDict[WUserLName] = stepFiveObj.userLName
        paramDict[WUserPic] =  ""
        paramDict[WBase64Pic] = skip ? "" : self.imageData != nil ? self.imageData.base64EncodedString() : ""
        paramDict[WUserCity] = stepFiveObj.userCity
        paramDict[WUserCountry] = stepFiveObj.userCountry
        paramDict[WUserLicenseLevel] = stepFiveObj.userLicenseLevel
        paramDict[WUserLicenseNumber] = stepFiveObj.userLicenseNumber
        paramDict[WUserDriver] = stepFiveObj.userType == "Driver" ? true : false
        paramDict[WUserInstructor] = stepFiveObj.isRegisteredDriver
        paramDict[WUserPhoneNumber] = ""
        paramDict[WDeviceToken] = UserDefaults.standard.value(forKey: "deviceToken") as? String ?? ""
        
        let apiNameSignUp = kAPINameSignUp
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameSignUp, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message == "No account with this email exists."{
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    } else {
                        UserDefaults.standard.setValue(responseObject?.object(forKey: "userId") as? String ?? "", forKey: "wheelzUserID")
                        UserDefaults.standard.setValue(self.stepFiveObj.userPasswordHash , forKey: "wheelzUserPassword")
                          UserDefaults.standard.setValue(((responseObject!.object(forKey: "firstName") as? String ?? "") ), forKey: "wheelzUserName")
                        UserDefaults.standard.setValue(((responseObject!.object(forKey: "lastName") as? String ?? "") ), forKey: "wheelzUserLastName")
                        UserDefaults.standard.set(responseObject?.object(forKey: "isDriver") as? Bool ?? false, forKey: "wheelzIsDriver")
                        UserDefaults.standard.set(responseObject?.object(forKey: "isInstructor") as? Bool ?? false, forKey: "wheelzIsInstructor")
                         UserDefaults.standard.setValue(responseObject?.object(forKey: "pic") as? String ?? "", forKey: "wheelzUserPic")
                        UserDefaults.standard.synchronize()
                        WAppData.appInfoSharedInstance.appUserInfo = WUserInfo.getUserInfo(responseObject!)
                        SignalRManager.sharedInstance.manageConnection()
                        
                        DispatchQueue.main.async {
                            if(self.stepFiveObj.userType == "Driver") {
                                let addVehicleVC = self.storyboard?.instantiateViewController(withIdentifier: "WAddVehicleVCID") as! WAddVehicleVC
                                addVehicleVC.isUpdateVehicle = false
                                addVehicleVC.isMainVehicleExists = false
                                addVehicleVC.isFirstTime = true
                                
                                self.navigationController?.pushViewController(addVehicleVC, animated: true)
                            }
                            else {
                                self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                                let tipVc = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                                
                                kAppDelegate.window?.rootViewController!.present(tipVc, animated: true, completion: nil)
                            }
                        }
                    }
                    
                } else {
                    //                    let responseString = String.init(data:data!, encoding: NSUTF8StringEncoding)
                    //                    dispatch_async(dispatch_get_main_queue()) {
                    //
                    //                        AlertController.alert("", message: responseString!,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                    //                            let reveal = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewControllerID")
                    //                            self.navigationController?.pushViewController(reveal!, animated: true)
                    //                            if position == 0 {
                    //                                // do nothing
                    //                            }
                    //                        })
                    //                    }
                }
            }
        }
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
