//
//  WLoginVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WLoginVC: UIViewController,UITextFieldDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var welcomeBgImage: UIImageView!
    
    let userObj = WUserInfo()
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = true
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        
        let expandTransform:CGAffineTransform = CGAffineTransform(scaleX: 1.03, y: 1.03);
        
        UIView.animate(withDuration: 8.0,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                       self.welcomeBgImage.transform = expandTransform
        }, completion: {
            //Code to run after animating
            (value: Bool) in
            return
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        if (UserDefaults.standard.value(forKey: "wheelzUserID") as? String)?.length > 0 {
            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
        }
        
        loginButton.setBorder(KAppWhiteColor, borderWidth: 2)
    }
    
    func isAllFieldVerified() ->Bool {
        
        var fieldVerified: Bool = false
        
        if (userObj.userName.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please enter your username.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter your username.", type: AlertStyle.Info, controller: self)
        } else if (!userObj.userName.isEmail()) {
            //presentAlert("", msgStr: "Please enter a valid username.", controller: self)
            presentFancyAlert("Sorry :(", msgStr: "Please enter a valid username.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userPassword.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please enter your password.", controller: self)
            presentFancyAlert("Sorry :(", msgStr: "Please enter your password.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userPassword.trimWhiteSpace().length < 8 || !userObj.userPassword.containsAlphaNumericOnly()) {
            //presentAlert("", msgStr: "Password must be at least 8 characters long.", controller: self)
            presentFancyAlert("Sorry :(", msgStr: "Password must be at least 8 characters long.", type: AlertStyle.Info, controller: self)
        } else {
            fieldVerified = true
        }
        
        return fieldVerified
    }
    
    // MARK: TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 500 {
            userObj.userName = textField.text!
        } else {
            userObj.userPassword = textField.text!
            userObj.userPasswordHash = textField.text!.md5()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 500 {
            let kTextField = getViewWithTag(501, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if textField.tag == 500 {
            if (str.length>55) {
                return false
            }
        } else {
            if (str.length>16) {
                return false
            }
            
            if (str.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted).location != NSNotFound) {
                return false
            }
        }
        return true
    }
    
    // MARK: UIButton Action Methods
    @IBAction func loginBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isAllFieldVerified() {
            self.callAPIForLogin()
        }
    }
    
    @IBAction func forgotPswrdBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let forgotPswrdVC = self.storyboard?.instantiateViewController(withIdentifier: "WForgotPswrdVCID")
        self.navigationController?.pushViewController(forgotPswrdVC!, animated: true)
    }
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "WSignUpStepOneVCID")
        self.navigationController?.pushViewController(signUpVC!, animated: true)
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForLogin() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserName] = userObj.userName
        paramDict[WUserPassword] = userObj.userPasswordHash
        
        let apiNameLogin = kAPINameLogin(userObj.userName, password: userObj.userPasswordHash)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameLogin, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        //presentFancyAlert("Sorry :(", msgStr: message, type: AlertStyle.Error, controller: self)
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    } else {
                        UserDefaults.standard.setValue(responseObject?.object(forKey: "userId") as? String ?? "", forKey: "wheelzUserID")
                        UserDefaults.standard.set(responseObject?.object(forKey: "deviceToken") as? String ?? "", forKey: "deviceToken")
                        UserDefaults.standard.setValue(self.userObj.userPasswordHash , forKey: "wheelzUserPassword")
                         UserDefaults.standard.setValue(((responseObject!.object(forKey: "firstName") as? String ?? "") ), forKey: "wheelzUserName")
                        UserDefaults.standard.setValue(((responseObject!.object(forKey: "lastName") as? String ?? "") ), forKey: "wheelzUserLastName")
                          UserDefaults.standard.set(responseObject?.object(forKey: "isDriver") as? Bool ?? false, forKey: "wheelzIsDriver")
                         UserDefaults.standard.set(responseObject?.object(forKey: "isInstructor") as? Bool ?? false, forKey: "wheelzIsInstructor")
                        if responseObject?.object(forKey: "pic") as? String != nil  {
                              UserDefaults.standard.setValue(String(format: "https://soireedev.azurewebsites.net/images/%@", (responseObject?.object(forKey: "pic") as? String)!), forKey: "wheelzUserPic")
                        } else {
                              UserDefaults.standard.setValue("", forKey: "wheelzUserPic")
                        }
                        kAppDelegate.isFirstLoad = true
                        
                        let userId = responseObject?.object(forKey: "userId") as? String ?? ""
                        let newTokenString = UserDefaults.standard.value(forKey: "deviceToken") as? String ?? ""
                        let oldTokenString = responseObject?.object(forKey: "deviceToken") as? String ?? ""
                        
                        if(oldTokenString.isEmpty && !newTokenString.isEmpty) {
                            let paramDict = NSMutableDictionary()
                            paramDict[WDeviceToken] = newTokenString
                            paramDict[WUserID] = userId
                            
                            let apiNameSaveDeviceToken = kAPINameSaveDeviceToken(userId, deviceToken: newTokenString)
                            
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
                                        }
                                    }
                                }
                            }
                        }
                        
                        UserDefaults.standard.synchronize()
                        WAppData.appInfoSharedInstance.appUserInfo = WUserInfo.getUserInfo(responseObject!)
                        SocketIOManager.sharedInstance.establishConnection()
                        
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
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
    
    // MARK:- --->UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
