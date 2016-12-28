//
//  WAddCardVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import Stripe

class WAddCardVC: UIViewController,UITextFieldDelegate, STPAddCardViewControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var securityCodeTextField: UITextField!
    @IBOutlet weak var monthPickerView: MonthYearPickerView!
    @IBOutlet weak var expirationButton: UIButton!
    @IBOutlet weak var expirationtextField: WCustomTextField!
    
    
    @IBOutlet weak var userNameTextField: WCustomTextField!
    @IBOutlet weak var blurBgView: UIView!
    var i = 0
    var arrayStr = Array<Any>()
     var isMainCardExists = Bool()
    var maskString = String()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customInit()
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //MARK:- Helper Methods
    func customInit()  {
        self.navigationItem.title = "Add Card"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        if Window_Width > 320  {
            scrollView.isScrollEnabled = false
        }

        self.cardNumberTextField.inputAccessoryView = addToolBar("Next",tag: self.cardNumberTextField.tag)
        self.securityCodeTextField.inputAccessoryView = addToolBar("Done",tag: self.securityCodeTextField.tag)
        self.expirationtextField.inputAccessoryView = addToolBar("Done",tag:self.expirationButton.tag)
        if Window_Width == 320 {
            radioButton.titleLabel?.font = kAppFont(16)
        }
        
        if isMainCardExists == false {
            radioButton.isSelected = true
            radioButton.isUserInteractionEnabled = false
        }
    }
    
    func  addToolBar(_ name:String, tag : NSInteger) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height - 46, width: Window_Width, height: 46)
        let nextButton = UIBarButtonItem(title: name, style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextBarButtonAction(_:)))
        nextButton.tag = tag
        //        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),nextButton]
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.setItems(toolbarItems, animated: false)
        return toolbar
    }

    //MARK:- Selector Methods
    @objc func nextBarButtonAction(_ button : UIButton) {
        if button.tag == 501 {
            let kTextField = getViewWithTag(502, view: self.view) as? UITextField
//            kTextField?.becomeFirstResponder()
            self.view.endEditing(true)
            blurBgView.isHidden = false

            if Window_Height == 480 {
                let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 260, 0.0)
                
                scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                var aRect : CGRect = self.view.frame
                aRect.size.height -= 260
                if (!aRect.contains(expirationtextField.frame.origin))
                {
                    self.scrollView.scrollRectToVisible(expirationtextField.frame, animated: true)
                }
            }
//            kTextField!.inputView = monthPickerView
            monthPickerView.onDateSelected = { (month: Int, year: Int) in
                let date = String(format: "%02d/%d", month, year)
                kTextField?.text = date
//                kTextField!.inputAccessoryView = self.addToolBar("Done",tag:kTextField!.tag+1)
                NSLog(date) // should show something like 05/2015
        }
        } else {
            self.view.endEditing(true)
        }
    }
    
    fileprivate func VerifyInput() ->Bool {
        
        var isVerified: Bool = false
        
        if (self.userNameTextField.text!.trimWhiteSpace().length == 0) {
            //alertLabel.text = "Please enter email address"
            presentAlert("", msgStr: "Please enter the same name as on card.", controller: self)
        } else if (self.cardNumberTextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please enter 16 digit card number.", controller: self)
        } else if (self.cardNumberTextField.text!.trimWhiteSpace().length != 19 ) {
            presentAlert("", msgStr: "Please enter a valid 16 digit card number.", controller: self)
        }  else if (self.expirationtextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please enter card expiry date.", controller: self)
        } else if (self.securityCodeTextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please enter card secure code", controller: self)
        } else if (self.securityCodeTextField.text!.trimWhiteSpace().length != 3 || !self.securityCodeTextField.text!.containsNumberOnly()) {
            presentAlert("", msgStr: "Please enter a valid 3 digit secure code.", controller: self)
        } else {
            isVerified = true
        }
        
        return isVerified
    }
    
    // MARK:- --->UIResponder Method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        blurBgView.isHidden = false
    }

    // MARK: TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.next {
            let kTextField = getViewWithTag(textField.tag+1, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view .endEditing(true)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField.tag == 501 {
            
            let replacementStringIsLegal = string.rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789").inverted) == nil
            
            if !replacementStringIsLegal
            {
                return false
            }
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet(charactersIn: "0123456789X").inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 16 && !hasLeadingOne) || length > 19
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 16) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            if length - index > 4
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 4))
                formattedString.appendFormat("%@-", prefix)
                index += 4
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
//            textField.text = formattedString as String
            textField.text = processString(formattedString)
            return false
        }
 //            arrayStr.addObject(newString)
//            processString()
       
        if textField.tag == 503 {
            if (newString.length>3) {
                return false
            }
        }
        return true
    }
    
    func processString(_ str : NSMutableString) -> String {
        arrayStr = str.components(separatedBy: "-")
        print("see",str.contains("-")," length",str.length)
        if str.contains("-") && str.length == 6{
            return String(format: "XXXX-%@",(arrayStr.last as? String)!)
        } else if str.contains("-") && str.length == 11{
            return String(format: "XXXX-XXXX-%@",(arrayStr.last as? String)!)
        } else if str.contains("-") && str.length == 16{
            return String(format: "XXXX-XXXX-XXXX-%@",(arrayStr.last as? String)!)
        } else if str.contains("-") && str.length == 19{
            return String(format: "XXXX-XXXX-XXXX-%@",(arrayStr.last as? String)!)
        } else {
            return str as String
        }
    }
     // MARK: UIButton Action Methods
    @IBAction func expirationDateButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        blurBgView.isHidden = false
        if Window_Height == 480 {
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 260, 0.0)
            
            scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect : CGRect = self.view.frame
            aRect.size.height -= 260
            if (!aRect.contains(expirationtextField.frame.origin))
            {
                self.scrollView.scrollRectToVisible(expirationtextField.frame, animated: true)
            }
        }
      
            monthPickerView.onDateSelected = { (month: Int, year: Int) in
            let date = String(format: "%02d/%d", month, year)
            let kTextField = getViewWithTag(502, view: self.view) as? UITextField
            kTextField?.text = date
        }
    }
    
    @IBAction func addCardButtonAction(_ sender: UIButton) {
        if VerifyInput() {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func radioButtonAction(_ sender: UIButton) {
        radioButton.isSelected = !radioButton.isSelected
    }
    
    @IBAction func datePickerNextButtonAction(_ sender: UIBarButtonItem) {
         blurBgView.isHidden = true
        if Window_Height == 480 {
            let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            self.view.endEditing(true)
            self.scrollView.isScrollEnabled = false
        }
          let kTextField = getViewWithTag(503, view: self.view) as? UITextField
        kTextField?.becomeFirstResponder()
        self.scrollView.isScrollEnabled = true
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
    }
}
