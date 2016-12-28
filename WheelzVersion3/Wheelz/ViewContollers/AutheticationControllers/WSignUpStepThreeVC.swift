//
//  WSignUpStepThreeVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import SCLAlertView

class WSignUpStepThreeVC: UIViewController,UIGestureRecognizerDelegate,UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var progressStepThreeView: UIProgressView!
    var stepThreeObj : WUserInfo!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        emailTextField.text = stepThreeObj.userName
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        passwordTextField.text = stepThreeObj.userPassword
        progressStepThreeView.setProgress(0.6, animated: true)
    }
    
    fileprivate func VerifyInput() ->Bool {
        
        var isVerified: Bool = false
        
        if (stepThreeObj.userName.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please enter your email address.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter your email address.", type: AlertStyle.Info, controller: self)
        } else if (!stepThreeObj.userName.isEmail()) {
            //presentAlert("", msgStr: "Please enter a valid email address.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid email address.", type: AlertStyle.Info, controller: self)
        } else if (stepThreeObj.userPassword.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please enter a password.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter a password.", type: AlertStyle.Info, controller: self)
        } else if (stepThreeObj.userPassword.trimWhiteSpace().length < 8 || !stepThreeObj.userPassword.containsAlphaNumericOnly()) {
            //presentAlert("", msgStr: "Password must be at least 8 characters long.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Password must be at least 8 characters long.", type: AlertStyle.Info, controller: self)
        } else {
            isVerified = true
        }
        
        return isVerified
    }
    
    // MARK: TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 500 {
            stepThreeObj.userName = textField.text!
        } else {
            stepThreeObj.userPassword = textField.text!
            stepThreeObj.userPasswordHash = textField.text!.md5()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 500 {
            let kTextField = getViewWithTag(501, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view .endEditing(true)
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
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.VerifyInput() {
            self.callAPIForCheckingExistingEmail()
        }
    }
    //MARK:- Web API Section
    fileprivate func callAPIForCheckingExistingEmail() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserName] = stepThreeObj.userName
        paramDict[WUserPassword] = stepThreeObj.userPasswordHash
        
        let apiNameLogin = kAPINameLogin(stepThreeObj.userName, password: stepThreeObj.userPasswordHash)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameLogin, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) -> Void in
            if (error == nil) {
                let responseString = String.init(data: data!, encoding: String.Encoding.utf8)
                
                if responseString == "{\"Message\":\"No account with this email exists.\"}"{
                    DispatchQueue.main.async(execute: {
                        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "WSignUpStepFourVCID") as! WSignUpStepFourVC
                        signUpVC.stepFourObj = self.stepThreeObj
                        if (self.navigationController?.topViewController is WSignUpStepThreeVC) {
                            self.navigationController?.pushViewController(signUpVC, animated: true)
                        }
                    })
                } else {
                    //presentFancyAlert("Sorry :(", msgStr: "Account with this username already exists.", type: AlertStyle.Info, controller: self)
                    AlertController.alert("Sorry :(", message: "Account with this username already exists.",controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                        if position == 0 {
                            // do nothing
                        }
                    })
                }
            } else {
                //presentFancyAlert("Sorry :(", msgStr: "Something went wrong.", type: AlertStyle.Info, controller: self)
                AlertController.alert("Sorry :(", message: "Something went wrong.",controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                    if position == 0 {
                        // do nothing
                    }
                })
            }
        }
    }

    // MARK:- --->UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
