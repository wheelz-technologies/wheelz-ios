//
//  WResetPasswordVC.swift
//  Wheelz
//
//  Created by Neha Chhabra on 06/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WResetPasswordVC: UIViewController {
    
    @IBOutlet var accessCodeTextField: UITextField!
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var alertLabel: UILabel!
    var userEmail = String()

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }

    //MARK:- Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Helper Methods
    func customInit() -> Void {
        self.navigationItem.title = "Reset Password"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        alertLabel.isHidden = true
    }

    func VerifyInput() ->Bool {
        
        var isVerified: Bool = false
        
        if (accessCodeTextField.text!.trimWhiteSpace().length == 0) {
            //alertLabel.text = "*Please enter your Access Code"
            presentAlert("", msgStr: "Please enter your access code.", controller: self)
        }else if (newPasswordTextField.text!.trimWhiteSpace().length == 0) {
            //alertLabel.text = "*Please enter new password"
            presentAlert("", msgStr: "Please enter your new password.", controller: self)
        } else if (newPasswordTextField.text!.trimWhiteSpace().length < 8) {
            //alertLabel.text = "*Password must be of minimum 8 characters"
            presentAlert("", msgStr: "Password must be at least 8 characters long.", controller: self)
        } else if (confirmPasswordTextField.text!.trimWhiteSpace().length == 0) {
            //alertLabel.text = "*Please enter a confirmation password"
            presentAlert("", msgStr: "Please enter a confirmation password.", controller: self)
        } else if (!(confirmPasswordTextField.text! == newPasswordTextField.text!) ) {
            //alertLabel.text = "*Password does not match"
            presentAlert("", msgStr: "Passwords do not match.", controller: self)
        }   else {
            isVerified = true
        }
        return isVerified
    }

    //MARK:- UIButton Action Methods
    @IBAction func submitButtonAction(_ sender: UIButton) {
        alertLabel.isHidden = false
        self.view.endEditing(true)
        if VerifyInput() {
            alertLabel.isHidden = true
            self.callAPIToSendPassword()
        } else {
        }
    }
    
    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 500 {
            let kTextField = getViewWithTag(501, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        }else if textField.tag == 501 {
            let kTextField = getViewWithTag(502, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view .endEditing(true)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if (str.length>16) {
            return false
        }
        return true
    }

    // MARK:- --->UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIToSendPassword() {
        var count = Int()
        count = 0;
        
        let paramDict = NSMutableDictionary()
        paramDict[WUserName] = userEmail
        paramDict[WUserPassword] = newPasswordTextField.text!.md5()
        paramDict[WAccessCode] = accessCodeTextField.text!
        
        let apiNameResetPassword = kAPINameResetPassword(userEmail, password: newPasswordTextField.text!.md5(), accessCode: accessCodeTextField.text!)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method:.post, apiName: apiNameResetPassword, hudType: .default) { (result :AnyObject?, error:NSError?,data:Data?) in
            
            if (result != nil) {
                DispatchQueue.main.async {
                    
                    var message = result?.object(forKey: "message") as? String ?? ""
                    if message != "OK" {
                        message = result?.object(forKey: "Message") as? String ?? ""
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            //if position == 0 {
                            //
                            //}
                        })
                    } else {
                        AlertController.alert("", message: "Password changed successfully.",controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 && message == "OK"{
                                self.view.endEditing(true)
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                    }
                }
            } else {
                if count == 1{
                    AlertController.alert("", message: "Password Sent Successfully")
                }
                count = 1
            }
        }
    }

}
