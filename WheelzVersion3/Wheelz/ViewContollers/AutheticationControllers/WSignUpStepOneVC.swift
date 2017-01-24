//
//  WSignUpStepOneVC.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 11/07/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WSignUpStepOneVC: UIViewController,UIGestureRecognizerDelegate,UITextFieldDelegate {
    
    var isDriving = Bool()
    
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var driverButton: UIButton!
    @IBOutlet weak var progressStepOneView: UIProgressView!
    var stepOneObj : WUserInfo!
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        stepOneObj = WUserInfo()
        stepOneObj.userType = "Student"
        stepOneObj.isDriver = false
        progressStepOneView.setProgress(0.2, animated: true)
        isDriving = false
    }

    // MARK: UIButton Action Methods
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "WSignUpStepTwoVCID") as! WSignUpStepTwoVC
        signUpVC.stepTwoObj = stepOneObj
        self.navigationController?.pushViewController(signUpVC, animated: true)
        
        
//        let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("WSignUpStepFourVCID") as! WSignUpStepFourVC
//        signUpVC.stepFourObj = self.stepOneObj
//        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func studentButtonAction(_ sender: UIButton) {
        
        self.studentButton.isSelected = true
        self.driverButton.isSelected = false
        self.stepOneObj = WUserInfo()
        self.stepOneObj.userType = "Student"
        stepOneObj.isDriver = false
        
        animateImageBounce(imageView: sender.imageView!)
    }
    
    @IBAction func driverButtonAction(_ sender: UIButton) {
        isDriving = true
        driverButton.isSelected = true
        studentButton.isSelected = false
        stepOneObj = WUserInfo()
        stepOneObj.userType = "Driver"
        stepOneObj.isDriver = true
        
        animateImageBounce(imageView: sender.imageView!)
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
