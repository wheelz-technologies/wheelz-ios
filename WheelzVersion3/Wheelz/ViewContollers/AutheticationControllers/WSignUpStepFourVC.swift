//
//  WSignUpStepFourVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WSignUpStepFourVC: UIViewController,UIGestureRecognizerDelegate,UITextFieldDelegate {
    @IBOutlet weak var licenseLevelSegmetController: UISegmentedControl!
    @IBOutlet weak var licenseNoTextField: UITextField!
    @IBOutlet weak var certifiedDriverButton: UIButton!
    @IBOutlet weak var progressStepFourView: UIProgressView!
    
    @IBOutlet weak var heightInstructorBtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomInstructorBtnConstraint: NSLayoutConstraint!
    
    var stepFourObj : WUserInfo!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        licenseNoTextField.text = stepFourObj.userLicenseNumber
        self.initializeSegmentController(stepFourObj.userType as NSString)
        progressStepFourView.setProgress(0.8, animated: true)
    }

    fileprivate func initializeSegmentController(_ userType : NSString) {
        
        licenseLevelSegmetController.subviews[0].tintColor = kAppOrangeColor
        licenseLevelSegmetController.subviews[1].tintColor = kAppOrangeColor
        licenseLevelSegmetController.subviews[2].tintColor = kAppOrangeColor
        
        if userType.isEqual(to: "Student") {
            licenseLevelSegmetController.selectedSegmentIndex = 0
//            licenseLevelSegmetController.setEnabled(false , forSegmentAtIndex: 2)
            licenseNoTextField.placeholder = "License Number"
            stepFourObj.isRegisteredDriver = false
         
            stepFourObj.userLicenseLevel = "G1"
            certifiedDriverButton.isHidden = true
        } else {
            certifiedDriverButton.isHidden = false
            licenseLevelSegmetController.selectedSegmentIndex = 2
            licenseLevelSegmetController.setEnabled(false , forSegmentAt: 0)
            licenseLevelSegmetController.setEnabled(false , forSegmentAt: 1)
            licenseLevelSegmetController.subviews[1].tintColor = UIColor.lightGray
            licenseLevelSegmetController.subviews[2].tintColor = UIColor.lightGray
            licenseNoTextField.placeholder = "License Number"
            stepFourObj.isRegisteredDriver = false
            certifiedDriverButton.isSelected = false
            stepFourObj.userLicenseLevel = "G"
        }
        licenseLevelSegmetController.setTitleTextAttributes([NSForegroundColorAttributeName: KAppWhiteColor], for: UIControlState.selected)
        licenseLevelSegmetController.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: UIControlState.disabled)
        licenseLevelSegmetController.setTitleTextAttributes([NSForegroundColorAttributeName: kAppOrangeColor], for: UIControlState())
    }
    
    fileprivate func isAllFieldVerified() ->Bool {
        
        var fieldVerified: Bool = false
        
        if (stepFourObj.userLicenseNumber.trimWhiteSpace().length == 0) {
            //presentAlert("", msgStr: "Please enter your license number.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter your license number.", type: AlertStyle.Info, controller: self)
        } else if ((!stepFourObj.userLicenseNumber.containsAlphaNumericOnly() || stepFourObj.userLicenseNumber.trimWhiteSpace().length != 15) && stepFourObj.userLicenseNumber.length > 0) {
            //presentAlert("", msgStr: "Please enter a valid license number.", controller: self)
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid license number.", type: AlertStyle.Info, controller: self)
        } else {
            fieldVerified = true
        }
        
        return fieldVerified
    }

    // MARK: TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        stepFourObj.userLicenseNumber = textField.text!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view .endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if (str.length>15) {
            return false
        }
        if (str.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted).location != NSNotFound) {
            return false
        }
        return true
    }
    
    // MARK: UIButton Action Methods
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.isAllFieldVerified() {
            let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "WSignUpStepFiveVCID") as! WSignUpStepFiveVC
            signUpVC.stepFiveObj = stepFourObj
            self.navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
    @IBAction func certifiedDriverButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        stepFourObj.isRegisteredDriver = !stepFourObj.isRegisteredDriver
        print(stepFourObj.isRegisteredDriver)
       
        if(sender.isSelected) {
            animateImageBounce(imageView: sender.imageView!)
        }
    }
    
    // MARK: Segment Controller Action Methods
    @IBAction func licenseLevelSegmetControllerAction(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            stepFourObj.userLicenseLevel = "G1"
        } else if sender.selectedSegmentIndex == 1 {
            stepFourObj.userLicenseLevel = "G2"
            print(stepFourObj.userLicenseLevel)
        } else {
            stepFourObj.userLicenseLevel = "G"
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
