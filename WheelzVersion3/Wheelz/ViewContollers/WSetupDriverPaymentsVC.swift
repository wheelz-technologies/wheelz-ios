//
//  WSetupDriverPaymentsVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-10-06.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import Stripe

class WSetupDriverPaymentsVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var dobDropdown: WCustomTextField!
    @IBOutlet weak var addressTextField: WCustomTextField!
    @IBOutlet weak var postalCodeTextField: WCustomTextField!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var sinTextField: WCustomTextField!
    var userIdentityObj = WUserIdentity()
    var birthDateSelected = false;
    
    var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    let unitFlags: NSCalendar.Unit = [.hour, .day, .month, .year]
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - UI Events
    @IBAction func addressEndedEditing(_ sender: AnyObject) {
        self.userIdentityObj.addressLine1 = addressTextField.text!.trimWhiteSpace()
    }
    
    @IBAction func postalCodeEndedEditing(_ sender: AnyObject) {
        let zipCode = postalCodeTextField.text!.replacingOccurrences(of: " ", with: "")
        if zipCode != "" {
            getCityAndState(zipCode.trimWhiteSpace())
        }
    }
    
    @IBAction func sinEndedEditing(_ sender: AnyObject) {
        let sinArray = sinTextField.text!.components(separatedBy: CharacterSet.decimalDigits.inverted)
        self.userIdentityObj.personalIdNumber = sinArray.joined(separator: "")
    }

    @IBAction func birthDatePickerValueChanged(_ sender: UIDatePicker) {
        let components = (calendar as NSCalendar).components(unitFlags, from: sender.date)
        
        self.userIdentityObj.birthDay = String(describing: components.day!)
        self.userIdentityObj.birthMonth = String(describing: components.month!)
        self.userIdentityObj.birthYear = String(describing: components.year!)
        
        birthDateSelected = true;
    }
    
    
    @IBAction func continueButtonAction(_ sender: AnyObject) {
        self.view .endEditing(true)
        verifyInput()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Setup Payments"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        sinTextField.delegate = self
        postalCodeTextField.delegate = self
        
        let currentDate: Date = Date()
        
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        var components: DateComponents = DateComponents()
        (components as NSDateComponents).calendar = calendar
        
        components.year = -16
        let maxDate: Date = (calendar as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        
        components.year = -100
        let minDate: Date = (calendar as NSCalendar).date(byAdding: components, to: currentDate, options: NSCalendar.Options(rawValue: 0))!
        
        birthDatePicker.minimumDate = minDate
        birthDatePicker.maximumDate = maxDate
        birthDatePicker.date = maxDate
    }
    
    func addCard() {
        let addBankViewController = self.storyboard?.instantiateViewController(withIdentifier: "WSetupDriverBankVCID") as! WSetupDriversBankAccountVC
        addBankViewController.userIdentityObj = self.userIdentityObj
        
        self.navigationController?.pushViewController(addBankViewController, animated: true)
    }
    
    func getCityAndState(_ zipCode: String) {
        let paramDict = NSMutableDictionary()
        paramDict[WZipCode] = zipCode
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: kAPINameGetCityState, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions()) as! [String : AnyObject]
                        
                        if let results = jsonResult["results"] as? [[String : AnyObject]] {
                            for result in results {
                                if let addressComponents = result["address_components"] as? [[String : AnyObject]] {
                                    
                                    let filteredStates = addressComponents.filter{ if let types = $0["types"] as? [String] {
                                        return types.contains("administrative_area_level_1") } else { return false } }
                                    
                                    let filteredCities = addressComponents.filter{ if let types = $0["types"] as? [String] {
                                        return types.contains("neighborhood") || types.contains("locality") } else { return false } }
                                    
                                    if !filteredStates.isEmpty && !filteredCities.isEmpty {
                                        self.userIdentityObj.city = filteredCities[0]["long_name"] as! String
                                        self.userIdentityObj.state = filteredStates[0]["short_name"] as! String
                                        self.userIdentityObj.zipCode = zipCode
                                        
                                        // Update the UI on the main thread
                                        DispatchQueue.main.async {
                                            
                                            self.cityStateLabel.text = "\(self.userIdentityObj.city), \(filteredStates[0]["long_name"] as! String)"
                                        }
                                    }
                                    else {
                                        self.userIdentityObj.city = ""
                                        self.userIdentityObj.state = ""
                                        self.userIdentityObj.zipCode = ""
                                        
                                        DispatchQueue.main.async {
                                            
                                            self.cityStateLabel.text = ""
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
    }
    
    func verifyInput() {
        if (!self.birthDateSelected) {
            presentFancyAlert("Whoops!", msgStr: "Please select your date of birth.", type: AlertStyle.Info, controller: self)
        } else if (self.userIdentityObj.personalIdNumber.length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please enter your Social Insurance Number.", type: AlertStyle.Info, controller: self)
        } else if (self.userIdentityObj.zipCode.length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please enter your zip code.", type: AlertStyle.Info, controller: self)
        } else if (self.userIdentityObj.addressLine1.length == 0) {
            presentFancyAlert("Whoops!", msgStr: "Please enter your address.", type: AlertStyle.Info, controller: self)
        } else {
            self.userIdentityObj.ip = getWiFiAddress()
            
            if (self.userIdentityObj.ip.length == 0) {
                presentFancyAlert("Whoops!", msgStr: "Please make sure you are connected to the Internet.", type: AlertStyle.Info, controller: self)
            }
            else {
                addCard()
            }
        }
        
    }
    
    func getWiFiAddress() -> String {
        var address = ""
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let flags = Int32((ptr?.pointee.ifa_flags)!)
                var addr = ptr?.pointee.ifa_addr.pointee
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr?.sa_family == UInt8(AF_INET) || addr?.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr!, socklen_t((addr?.sa_len)!), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let tempAddress = String(validatingUTF8: hostname) {
                                address = tempAddress
                                break
                            }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    // MARK: UITextViewDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var maxLength = 0
        
        if(textField.tag == 500) {
            maxLength = 9 //for SIN textfield
        }
        else {
            maxLength = 7 //for Postal Code textfield
        }
        
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
