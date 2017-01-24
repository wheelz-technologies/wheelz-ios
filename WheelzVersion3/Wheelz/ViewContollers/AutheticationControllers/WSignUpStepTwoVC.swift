//
//  WSignUpStepTwoVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WSignUpStepTwoVC: UIViewController,UIGestureRecognizerDelegate,UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var progressStepTwoView: UIProgressView!
    @IBOutlet weak var importantLabel: UILabel!
    var stepTwoObj : WUserInfo!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        firstNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
        lastNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
        firstNameTextField.text = stepTwoObj.userFName
        lastNameTextField.text = stepTwoObj.userLName
        progressStepTwoView.setProgress(0.4, animated: true)
        
        if((stepTwoObj.userType as NSString).isEqual(to: "Driver"))
        {
            lastNameTextField.placeholder = "Last name"
            importantLabel.isHidden = false
        }
    }
    
    
    fileprivate func VerifyInput() ->Bool {
        
        var isVerified: Bool = false
        
        if (stepTwoObj.userFName.trimWhiteSpace().length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please, enter your first name.", type: AlertStyle.Info, controller: self)
        } else if (!stepTwoObj.userFName.containsAlphabetsOnly()) {
            //presentAlert("", msgStr: "Please enter valid first name.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid first name.", type: AlertStyle.Info, controller: self)
        }
        else if (stepTwoObj.isDriver && stepTwoObj.userLName.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please, enter your last name.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please, enter your last name.", type: AlertStyle.Info, controller: self)
        }
        else if (!stepTwoObj.userLName.containsAlphabetsOnly() && stepTwoObj.userLName.trimWhiteSpace().length > 0) {
            //presentAlert("", msgStr: "Please enter valid last name.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid last name.", type: AlertStyle.Info, controller: self)
        } else {
            isVerified = true
        }
        
        return isVerified
    }

    // MARK: TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 500 {
            stepTwoObj.userFName = textField.text!
        } else {
            stepTwoObj.userLName = textField.text!
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
        if (str.length>30) {
            return false
        }
        return true
    }

    // MARK: UIButton Action Methods
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if VerifyInput() {
            let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "WSignUpStepThreeVCID") as! WSignUpStepThreeVC
            signUpVC.stepThreeObj = stepTwoObj
            self.navigationController?.pushViewController(signUpVC, animated: true)
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
