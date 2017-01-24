//
//  WSetupDriversBankAccountVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-10-23.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import Stripe
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


class WSetupDriversBankAccountVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var routingNumberTextField: WCustomTextField!
    
    @IBOutlet weak var accountNumberTextField: WCustomTextField!
    
    @IBOutlet weak var tappableLabel: UITextView!
    
    let firstName = UserDefaults.standard.value(forKey: "wheelzUserName") as? String
    
    let lastName = UserDefaults.standard.value(forKey: "wheelzUserLastName") as? String
    
    var userIdentityObj : WUserIdentity!
    var routingNumber = ""
    var accountNumber = ""
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(WSetupDriversBankAccountVC.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        self.customInit()
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
 
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Setup Payments"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("infoIcon",controller : self)
        routingNumberTextField.delegate = self
        accountNumberTextField.delegate = self
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let attributedText = NSMutableAttributedString(string: "By proceeding, you agree to our Service Agreement and Stripe Connected Account Agreement",attributes: [NSForegroundColorAttributeName : KAppPlaceholderColor,NSFontAttributeName:UIFont(name:"HelveticaNeue-Light", size:9)!,NSParagraphStyleAttributeName:style])
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.styleSingle.rawValue, range: (attributedText.string as NSString).range(of: "Service Agreement"))
        attributedText.addAttribute(NSUnderlineStyleAttributeName , value:NSUnderlineStyle.styleSingle.rawValue, range: (attributedText.string as NSString).range(of: "Stripe Connected Account Agreement"))
        attributedText.addAttribute(NSLinkAttributeName, value: "http://www.learnwheelz.com/terms-of-use", range: (attributedText.string as NSString).range(of: "Service Agreement"))
        attributedText.addAttribute(NSLinkAttributeName, value: "https://stripe.com/ca/connect-account/legal", range: (attributedText.string as NSString).range(of: "Stripe Connected Account Agreement"))
        tappableLabel.attributedText = attributedText
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        let paymentsTipVc = self.storyboard?.instantiateViewController(withIdentifier: "WPaymentSetupTipVCID") as! WPaymentSetupTipVC
        paymentsTipVc.modalPresentationStyle = .overCurrentContext
        
        kAppDelegate.window?.rootViewController!.present(paymentsTipVc, animated: true, completion: nil)
    }
    
    func generateBankToken() {
        let account = STPBankAccount()
        account.accountHolderName = "\(firstName) \(lastName)"
        account.accountHolderType = STPBankAccountHolderType.individual
        account.country = "CA"
        account.currency = "CAD"
        account.routingNumber = routingNumberTextField.text!
        account.accountNumber = accountNumberTextField.text!
        
        let theCompletionHandler: STPTokenCompletionBlock = {token, error in
            if error != nil {
                AlertController.alert("", message: (error?.localizedDescription)!)
            } else {
                if(token != nil && token?.tokenId.length > 0)
                {
                    self.submitTokenToBackend(token!)
                }
            }
        }
        
        Stripe.createToken(with: account, completion: theCompletionHandler)
    }
    
    func submitTokenToBackend(_ token: STPToken)
    {
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WStripeToken] = token.tokenId
        paramDict[WZipCode] = self.userIdentityObj.zipCode
        paramDict[WState] = self.userIdentityObj.state
        paramDict[WUserCity] = self.userIdentityObj.city
        paramDict[WAddressLine1] = self.userIdentityObj.addressLine1
        paramDict[WBirthDay] = self.userIdentityObj.birthDay
        paramDict[WBirthMonth] = self.userIdentityObj.birthMonth
        paramDict[WBirthYear] = self.userIdentityObj.birthYear
        paramDict[WPersonalIdNumber] = self.userIdentityObj.personalIdNumber
        paramDict[WIp] = self.userIdentityObj.ip
        
        let apiNameSetupPaymentsProfile = kAPINameSetupDriverPaymentsProfile()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameSetupPaymentsProfile, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                DispatchQueue.main.async(execute: {
                    let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
                    let paymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WDriverPaymentsVCID") as! WDriverPaymentsVC
                    drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
                    drawerController.setDrawerState(.closed, animated: true)
                })
            }
        }
    }
    
    func verifyInput() {
        if (self.routingNumber.length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please enter your Routing Number.", type: AlertStyle.Info, controller: self)
        } else if (self.accountNumber.length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please enter your Account Number.", type: AlertStyle.Info, controller: self)
        } else {
            generateBankToken()
        }
    }
    
    // UI Events
    
    @IBAction func submitButtonClick(_ sender: AnyObject) {
        self.view.endEditing(true)
        verifyInput()
    }
    
    @IBAction func routingNumberEndedEditing(_ sender: AnyObject) {
        self.routingNumber = routingNumberTextField.text!.replacingOccurrences(of: " ", with: "")
    }
    
    @IBAction func accountNumberEndedEditing(_ sender: AnyObject) {
        self.accountNumber = accountNumberTextField.text!.replacingOccurrences(of: " ", with: "")
    }
    
    
    // MARK: UITextViewDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 0
        
        if(textField.tag == 500) {
            maxLength = 9 //for Routing Number textfield
        }
        else {
            maxLength = 12 //for Account Number textfield
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
