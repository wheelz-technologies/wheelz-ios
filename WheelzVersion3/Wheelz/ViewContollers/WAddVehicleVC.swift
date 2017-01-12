//
//  WAddVehicleVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WAddVehicleVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate {
    
    var vehicleObj : WVehiclesInfo!
    var isFirstTime = false //equals True only if adding vehicle during driver registration
    
    var modelArr  = NSMutableArray()
    var makeArr = NSMutableArray()
    var dateArr = NSMutableArray()
    
    var pickerOption : NSInteger = 0
    var isMainVehicleExists = Bool()
    var isOnlyVehicle = false
    var isUpdateVehicle = Bool()
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var vinTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var vehicleAddUpdateButton: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var deleteButton: UIButton!
     let optionPicker = UIPickerView(frame: CGRect(x: 0, y: Window_Height-184, width: Window_Width, height: 184))
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callAPIForGetVehicleDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customInit()
    }
    
    //MARK:- Helper Methods
    fileprivate func customInit() {
        
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
        if Window_Width > 320  {
            scrollView.isScrollEnabled = false
        }

        makeTextField.isUserInteractionEnabled =  false
        modelTextField.isUserInteractionEnabled =  false
        yearTextField.isUserInteractionEnabled =  false
        if isUpdateVehicle == true {
            makeTextField.text = vehicleObj!.make
            modelTextField.text = vehicleObj!.model
            yearTextField.text = vehicleObj!.year
            vinTextField.text = vehicleObj!.vin
            radioButton.isSelected = vehicleObj.isMain
            radioButton.isUserInteractionEnabled = isMainVehicleExists == true ? false : true
            vehicleAddUpdateButton.setTitle("UPDATE VEHICLE", for: UIControlState())
            self.navigationItem.title = "Edit Vehicle"
        } else {
            deleteButton.isHidden =  true
            vehicleAddUpdateButton.setTitle("ADD VEHICLE", for: UIControlState())
            self.navigationItem.title = "Add Vehicle"
            vehicleObj = WVehiclesInfo()
            if isMainVehicleExists == false {
                radioButton.isSelected = true
                radioButton.isUserInteractionEnabled = false
                vehicleObj!.isMain = true
            }
        }
        
        if(isFirstTime){
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.setHidesBackButton(true, animated:true);
        }
        
        if(isOnlyVehicle) {
            self.deleteButton.isHidden = true
        }
    }
    
    func pickerTapped(_ sender: UITapGestureRecognizer){
        if pickerOption == 0 {
            let makeInfo = makeArr.object(at: 0) as! WVehiclesInfo
            
            makeTextField.text = makeInfo.make
            vehicleObj!.make = makeInfo.make
            modelArr = makeInfo.modelArray
            self.modelTextField.isUserInteractionEnabled =  true
            modelTextField.inputView = optionPicker
            modelTextField.inputAccessoryView = addToolBar("Next", btnTag: 501)
            modelTextField.text = ""
            yearTextField.text = ""
            vinTextField.text = ""
        } else if pickerOption == 1 {
            let modelInfo = modelArr.object(at: 0) as! WVehiclesInfo
            modelTextField.text = modelInfo.model
            vehicleObj!.model = modelInfo.model
            self.yearTextField.isUserInteractionEnabled =  true
            dateArr = modelInfo.yearArray
            self.yearTextField.inputView = self.optionPicker
            self.yearTextField.inputAccessoryView = self.addToolBar("Next", btnTag: 502)
            yearTextField.text = ""
        } else {
            let dateInfo = dateArr.object(at: 0) as! WVehiclesInfo
            yearTextField.text = dateInfo.year
            yearTextField.text = dateInfo.year
            vehicleObj!.year = dateInfo.year
        }
    }
    
    func  addToolBar(_ name:String, btnTag : NSInteger) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height - 46, width: Window_Width, height: 46)
        let nextButton = UIBarButtonItem(title: name, style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextBarButtonAction(_:)))
        nextButton.tag = btnTag
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),nextButton]
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.setItems(toolbarItems, animated: false)
        return toolbar
    }
    
    func dismissKeyboard()  {
        self.view.endEditing(true)
        scrollView.contentOffset  = CGPoint(x: 0, y: -45)
    }
    
    //MARK:- Selector Methods
    @objc func nextBarButtonAction(_ button : UIButton) {
        let kTextField = getViewWithTag(button.tag+1, view: self.view) as? UITextField
        if button.tag == 500  && modelArr.count > 0 {
            pickerOption = 1
            optionPicker.reloadAllComponents()
            kTextField?.becomeFirstResponder()
        } else if button.tag == 501   && dateArr.count > 0{
            pickerOption = 2
            optionPicker.reloadAllComponents()
            kTextField?.becomeFirstResponder()
        } else if button.tag == 502 {
            kTextField?.becomeFirstResponder()
        } else {
            self.dismissKeyboard()
        }
       
    }

    fileprivate func VerifyInput() ->Bool {
        
        var isVerified: Bool = false
        if (self.makeTextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please select a maker.", controller: self)
        } else if (self.modelTextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please select a model.", controller: self)
        }  else if (self.yearTextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please select a year.", controller: self)
        } else {
            isVerified = true
        }
        
        return isVerified
    }
    
    // MARK: GestureRecogniser Delegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 500:
            pickerOption = 0
            optionPicker.reloadAllComponents()
            break
        case 501:
            pickerOption = 1
            optionPicker.reloadAllComponents()
            break
        case 502:
            pickerOption = 2
            optionPicker.reloadAllComponents()
            break
        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 500:
            vehicleObj!.make = textField.text!
            break
        case 501:
            vehicleObj!.model = textField.text!
            break
        case 502:
            vehicleObj!.year = textField.text!
            break
        default:
            vehicleObj!.vin = textField.text!
            break
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if textField.tag == 503 {
            if (str.length>17) {
                return false
            }
        }
//        if textField.tag == 501 {
//            if (str.length>15) {
//                return false
//            }
//        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.done {
            dismissKeyboard()
        }
        return true
    }
    
        //MARK:- UIButton Action Methods
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        print(vehicleObj.vehicleId)
        AlertController.alert("", message: "Delete this vehicle?",controller: self, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
            if position == 1 {
                self.callAPIForDeleteVehicle(self.vehicleObj.vehicleId)
            }
        })
    }

    @IBAction func addVehicleButtonAction(_ sender: UIButton) {
          self.view .endEditing(true)
        if VerifyInput() {
            if isUpdateVehicle {
                print(vehicleObj.vehicleId)
                callAPIForUpdateVehicle(vehicleObj.vehicleId)
            } else {
                callAPIForCreateNewVehicle()
            }
        }
    }
    
    @IBAction func radioButtonAction(_ sender: UIButton) {
        radioButton.isSelected = !radioButton.isSelected
        if radioButton.isSelected {
            vehicleObj!.isMain = true
            animateImageBounce(imageView: sender.imageView!)
        } else {
            vehicleObj!.isMain = false
        }
    }
   
    //MARK:- UIPicker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if pickerOption == 0 {
            return  makeArr.count
        } else if pickerOption == 1 {
            print(modelArr.count)
            return  modelArr.count
        } else {
            return dateArr.count
        }
        
    }
    
    // The data to return for the row and component (column) that's being passed in
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
        if pickerOption == 0 {
             let makeInfo = makeArr.object(at: row) as! WVehiclesInfo
            return makeInfo.make
        } else if pickerOption == 1{
            let modelInfo = modelArr.object(at: row) as! WVehiclesInfo
            return modelInfo.model
        } else {
            let dateInfo = dateArr.object(at: row) as! WVehiclesInfo
            return dateInfo.year
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
        if pickerOption == 0 {
            let makeInfo = makeArr.object(at: row) as! WVehiclesInfo

            makeTextField.text = makeInfo.make
            vehicleObj!.make = makeInfo.make
            modelArr = makeInfo.modelArray
            self.modelTextField.isUserInteractionEnabled =  true
            modelTextField.inputView = optionPicker
            modelTextField.inputAccessoryView = addToolBar("Next", btnTag: 501)
            modelTextField.text = ""
            yearTextField.text = ""
            vinTextField.text = ""
            
        } else if pickerOption == 1 {
             let modelInfo = modelArr.object(at: row) as! WVehiclesInfo
           modelTextField.text = modelInfo.model
            vehicleObj!.model = modelInfo.model
            self.yearTextField.isUserInteractionEnabled =  true
            dateArr = modelInfo.yearArray
            self.yearTextField.inputView = self.optionPicker
            self.yearTextField.inputAccessoryView = self.addToolBar("Next", btnTag: 502)
            yearTextField.text = ""
        } else {
            print(dateArr.count)
             let dateInfo = dateArr.object(at: row) as! WVehiclesInfo
            yearTextField.text = dateInfo.year
            yearTextField.text = dateInfo.year
            vehicleObj!.year = dateInfo.year
        }
    }

    //MARK:- Web API Section
    
    fileprivate func callAPIForGetVehicleDetail() {
        
        let paramDict = NSMutableDictionary()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: "getVehicleDetail", hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let response  =  responseObject as! NSDictionary
                    
                    let responseArray = response["makes"] as! NSMutableArray
                    if responseArray.count < 1 {
                        AlertController.alert("", message: "Looks like you haven't added any vehicles yet.",controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                            }
                        })
                    } else {
                        self.makeArr = WVehiclesInfo.getVehiclesDetail(responseObject! as! NSMutableDictionary) as NSMutableArray
                        self.makeTextField.inputView = self.optionPicker
                        self.makeTextField.inputAccessoryView = self.addToolBar("Next", btnTag: 500)
                        self.optionPicker.delegate = self
                       
                         if self.isUpdateVehicle == true {
                            self.makeTextField.isUserInteractionEnabled =  true
                         } else {
                            self.makeTextField.isUserInteractionEnabled =  true
                            self.modelTextField.isUserInteractionEnabled =  true
                            self.yearTextField.isUserInteractionEnabled =  true
                        }
                        
                        let recognizer = UITapGestureRecognizer(target: self, action:#selector(WAddVehicleVC.pickerTapped(_:)))
                        recognizer.delegate = self
                        self.optionPicker.addGestureRecognizer(recognizer)
                    }
                }
            }
        }
    }
    
    fileprivate func callAPIForCreateNewVehicle() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WMake] = vehicleObj!.make
        paramDict[WModel] = vehicleObj!.model
        paramDict[WYear] = vehicleObj!.year
        paramDict[WVin] = vehicleObj!.vin
        paramDict[WAvailableForTest ] = vehicleObj!.isAvailableForTest
        paramDict[WIsMain] = vehicleObj!.isMain
        
        let apiNameCreateNewVehicle = kAPINameCreateNewVehicle()
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameCreateNewVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message != "" {
                        if(self.isFirstTime) {
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                                let tipVc = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                                tipVc.orderedViewControllers = [newViewControllerFromMain(name: "WSignUpTipVCID"),
                                                                newViewControllerFromMain(name: "WDriverSignUpTip1VCID"),
                                                                newViewControllerFromMain(name: "WDriverSignUpTip2VCID"),
                                                                newViewControllerFromMain(name: "WDriverSignUpTip3VCID")]
                                
                                kAppDelegate.window?.rootViewController!.present(tipVc, animated: true, completion: nil)
                            }
                        }
                        else{
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
//                        NSUserDefaults.standardUserDefaults().setValue(responseObject?.objectForKey("userId") as? String ?? "", forKey: "wheelzUserID")
//                        NSUserDefaults.standardUserDefaults().setValue(((responseObject!.objectForKey("firstName") as! String) + " " + (responseObject!.objectForKey("lastName") as! String) ), forKey: "wheelzUserName")
//                        NSUserDefaults.standardUserDefaults().synchronize()
//                        WAppData.appInfoSharedInstance.appUserInfo = WUserInfo.getUserInfo(responseObject!)
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                if(self.isFirstTime) {
                                    DispatchQueue.main.async {
                                        self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                                    }
                                }
                                else{
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        })
                    }
                }
            }
    }
    }
    
    func callAPIForUpdateVehicle(_ vehicleID: String) {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WVehicleID] = vehicleID
        paramDict[WMake] = vehicleObj!.make
        paramDict[WModel] = vehicleObj!.model
        paramDict[WYear] = vehicleObj!.year
        paramDict[WVin] = vehicleObj!.vin
        paramDict[WAvailableForTest ] = vehicleObj!.isAvailableForTest
        paramDict[WIsMain] = vehicleObj!.isMain
        let apiNameUpdateVehicle = kAPINameUpdateVehicle()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUpdateVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    if message != "" {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                            AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    }
                }
            }
        }
    }

    func callAPIForDeleteVehicle(_ vehicleID: String) {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WVehicleID] = vehicleID
        let apiNameGetVehicle = kAPINameDeleteVehicle(paramDict.value(forKey: WVehicleID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .delete, apiName: apiNameGetVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let msg = responseObject?.object(forKey: "Message") as? String ?? ""
                    if msg != "" {
                        AlertController.alert("", message: msg,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                            

                            }
                        })
                    } else {
                           self.navigationController?.popViewController(animated: true)                    }
                }
            }
        }
            }
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
   
        }
