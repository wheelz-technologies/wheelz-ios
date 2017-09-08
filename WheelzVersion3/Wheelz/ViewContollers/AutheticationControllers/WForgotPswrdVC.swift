//
//  WForgotPswrdVC.swift
//  Fender
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WForgotPswrdVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var horizontalLayoutConstraintEmailTextField: NSLayoutConstraint! // Default value is zero
  var tempPasswordString = String()
    let userObj = WUserInfo()

    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Recover Password"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
        alertLabel.text = ""
        
        // for managing on iPhone4 when on keyboad appear
        if Window_Height < 500 {
            horizontalLayoutConstraintEmailTextField.constant = -34
        }
    }
    
    // MARK:- --->UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //generate random 6 digit random string for tempPassword
//    func randomStringWithLength (len : Int) -> NSString {
//        
//        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        
//        let randomString : NSMutableString = NSMutableString(capacity: len)
//        
//        for (var i=0; i < len; i += 1){
//            let length = UInt32 (letters.length)
//            let rand = arc4random_uniform(length)
//            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
//        }
//        
//        return randomString
//    }
    
    
    @IBAction func onSendPassword(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if ((emailTextField.text?.trimWhiteSpace().isEmail()) == true) {
            callAPIToSendPassword()
        } else if emailTextField.text?.trimWhiteSpace().length == 0 {
            //alertLabel.text = "Please enter username"
            presentFancyAlert("Whoops!", msgStr: "Please enter your username.", type: AlertStyle.Info, controller: self)
        } else {
            //alertLabel.text = "Please enter valid username"
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid username.", type: AlertStyle.Info, controller: self)
        }
    }
    
    // MARK:- Textfield Delegate Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIToSendPassword() {
        var count = Int()
        count = 0;
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserName] = emailTextField.text!.trimWhiteSpace()
        paramDict[WtempPassword] = tempPasswordString
        
        let apiNameResetPassword = kAPINameGenerateAccessCode(emailTextField.text!.trimWhiteSpace())
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method:.post, apiName: apiNameResetPassword, hudType: .default) { (result :AnyObject?, error:NSError?,data:Data?) in
            
            if (result != nil) {
                DispatchQueue.main.async {
                    
                    var message = result?.object(forKey: "message") as? String ?? ""
                    if message != "OK" {
                        message = result?.object(forKey: "Message") as? String ?? ""
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
//                            if position == 0 {
//                               
//                            }
                        })

                    } else {
                        AlertController.alert("", message: "Check your email! We've sent you an access code.",controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 && message == "OK"{
                                self.view.endEditing(true)
                                let forgotPswrdVC = self.storyboard?.instantiateViewController(withIdentifier: "WResetPasswordVCID") as! WResetPasswordVC
                                forgotPswrdVC.userEmail = self.emailTextField.text!
                                self.navigationController?.pushViewController(forgotPswrdVC, animated: true)
                            }
                        })

                    }
                                    }
            } else {
                if count == 1 {
                    AlertController.alert("", message: "Password Sent Successfully")
                }
                count = 1
            }
        }
    }
    
}
