//
//  WEditProfileVC.swift
//  Wheelz
//
//  Created by Neha Chhabra on 27/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts
import AddressBookUI

class WEditProfileVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
  
    var imageData : Data!
    var userObj : WUserInfo!
    var passwordEdited: Bool = false;
    
    var picker:UIImagePickerController?=UIImagePickerController()
    let optionPicker = UIPickerView(frame: CGRect(x: 0, y: Window_Height-184, width: Window_Width, height: 184))

    var location: Location? {
        didSet {
            //            locationNameLabel.text = location.flatMap({ $0.title }) ?? "No location selected"
        }
    }
    @IBOutlet weak var editAccountTableView: UITableView!
    @IBOutlet weak var profileImageButton: UIButton!

    @IBOutlet weak var instructorButton: UIButton!
    @IBOutlet weak var driverButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
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
    func customInit() {
        self.navigationItem.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
          self.profileImageView.setImageWithUrl(URL(string: self.userObj.userImage)!, placeHolderImage: UIImage(named: "default.png"))
        if (self.userObj.userImage != "") {
            //self.profileImageView.layer.borderColor = UIColor.gray.cgColor
            //self.profileImageView.layer.borderWidth = 2.0
        } else {
            self.profileImageView.layer.borderColor = UIColor.clear.cgColor
        }


        getRoundImage(self.profileImageView)
        optionPicker.dataSource = self
        optionPicker.delegate = self
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == false {
            instructorButton.isHidden = true
            driverButton.isHidden = true
        }
        instructorButton.isSelected = userObj.isRegisteredDriver
        driverButton.isSelected = userObj.isDriver
    }
    
    func  addToolBar(_ name:NSString, btnTag : NSInteger) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height - 46, width: Window_Width, height: 46)
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextBarButtonAction(_:)))
        //        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        nextButton.tag = btnTag
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),nextButton]
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.setItems(toolbarItems, animated: false)
        return toolbar
    }

    @objc func nextBarButtonAction(_ button : UIButton) {
        let kTextField = getViewWithTag(button.tag + 1, view: self.view) as? UITextField
        kTextField?.becomeFirstResponder()
        if (button.tag == 554) {
            self.view.endEditing(true)
            locationPickerButtonAction(button)
        }
        print("BUTTON TAG",button.tag)
    }

    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker?.delegate = self
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker?.navigationBar.tintColor = UIColor.white
            self .present(picker!, animated: true, completion: nil)
        } else {
            openGallery()
        }
    }
    
    func openGallery() {
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker?.delegate = self
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(picker!, animated: true, completion: nil)
            picker?.navigationBar.tintColor = UIColor.white
        }
    }
    
    //MARK:- UIButton Validations
    func isAllFieldVerified()  {
        if (userObj.userFName.length == 0) {
            //AlertController.alert("",message: "Please enter first name.")
            presentFancyAlert("Whoops!", msgStr: "Please enter first name.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userPassword.trimWhiteSpace().length == 0) {
            //AlertController.alert("",message: "Please enter a password.")
            presentFancyAlert("Whoops!", msgStr: "Please enter a password.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userPassword.trimWhiteSpace().length < 8 || !userObj.userPassword.containsAlphaNumericOnly()) {
            //AlertController.alert("",message: "Password must be at least 8 characters long.")
            presentFancyAlert("Whoops!", msgStr: "Password must be at least 8 characters long.", type: AlertStyle.Info, controller: self)
        } else if (!userObj.userFName.containsAlphabetsOnly()) {
            //AlertController.alert("",message: "Please enter valid first name.")
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid first name.", type: AlertStyle.Info, controller: self)
        }  else if (userObj.userLName !=  "" && !userObj.userLName.containsAlphabetsOnly()) {
            //AlertController.alert("",message: "Please enter a valid last name.")
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid last name.", type: AlertStyle.Info, controller: self)
        }  else if (userObj.userPhone != "" && userObj.userPhone.length < 10) {
            //AlertController.alert("",message: "Please enter a valid contact number.")
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid contact number.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userLicenseLevel.length == 0){
            //AlertController.alert("",message: "Please select your license level.")
            presentFancyAlert("Whoops!", msgStr: "Please select your license level.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userLicenseNumber.length == 0){
            //AlertController.alert("",message: "Please enter a license number.")
            presentFancyAlert("Whoops!", msgStr: "Please enter your license number.", type: AlertStyle.Info, controller: self)
        } else if (userObj.userLicenseNumber.length != 15){
            //AlertController.alert("",message: "Please enter a valid license number.")
            presentFancyAlert("Whoops!", msgStr: "Please enter a valid license number.", type: AlertStyle.Info, controller: self)
        } else {
            callAPIForUpdateUserProfile()
        }
        
    }
    //MARK:- UIImage Picker Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: nil)
        profileImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.imageData = Data()
        self.imageData = UIImagePNGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage)!)!

        //sets the selected image to image view
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker .dismiss(animated: true, completion: nil)
    }

    //MARK:- PickerView Delegate and Datasource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let arr = ["G","G1","G2"]
        userObj.userLicenseLevel = arr[row]
        print(userObj.userLicenseLevel)
        editAccountTableView.reloadData()
    }
   
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let arr = ["G","G1","G2"]
        return arr[row]
    }
    //MARK:- UITableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                   return 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCommonTextFieldTVCellID", for: indexPath) as! WCommonTextFieldTVCell
        
        cell.commonTextField.returnKeyType = UIReturnKeyType.next
        cell.commonTextField.delegate = self
        cell.commonTextField.tag = 550 + indexPath.row
        cell.commonTextField.autocapitalizationType = UITextAutocapitalizationType.none
        cell.commonTextField.isSecureTextEntry = false
        cell.commonButton.isHidden = true
        switch indexPath.row {
        case 0:
            cell.commonTextField.placeholder = "Email Address"
            cell.commonTextField.text = userObj.userEmail
            cell.commonTextField.isUserInteractionEnabled = false

            break
        case 1:
            cell.commonTextField.placeholder = "Password"
            //cell.commonTextField.userInteractionEnabled = false
            cell.commonTextField.text = "Password"
            cell.commonTextField.isSecureTextEntry = true

            break
        case 2:
            cell.commonTextField.placeholder = "First Name"
            cell.commonTextField.text = userObj.userFName
            cell.commonTextField.autocapitalizationType = UITextAutocapitalizationType.words

//            cell.commonTextField.inputAccessoryView = addToolBar("Next")
            
            break
        case 3:
            cell.commonTextField.placeholder = "Last Name (Optional)"
            cell.commonTextField.text = userObj.userLName
            cell.commonTextField.autocapitalizationType = UITextAutocapitalizationType.words

            break
        case 4:
            cell.commonTextField.placeholder = "Phone (Optional)"
            cell.commonTextField.text = userObj.userPhone
            cell.commonTextField.keyboardType = UIKeyboardType.numberPad
            cell.commonTextField.inputAccessoryView = addToolBar("Next", btnTag: cell.commonTextField.tag)

            break
        case 5:
            cell.commonTextField.placeholder = "Address (Optional)"
            cell.commonTextField.text = userObj.userLocation

            cell.commonTextField.isUserInteractionEnabled = false
            cell.commonButton.isHidden = false
            cell.commonButton.addTarget(self, action: #selector(locationPickerButtonAction(_:)),
                                        for: .touchUpInside)
            print(self.userObj.userCountry)

            break
            
        case 6:
            cell.commonTextField.placeholder = "License Level"
            print(userObj.userLicenseLevel)
            cell.commonTextField.text = userObj.userLicenseLevel
            cell.commonTextField.inputView = optionPicker
            cell.commonTextField.inputAccessoryView = addToolBar("one", btnTag: cell.commonTextField.tag)

            break
        case 7:
            cell.commonTextField.placeholder = "License Number"
            cell.commonTextField.text = userObj.userLicenseNumber
            cell.commonTextField.returnKeyType = UIReturnKeyType.done

            break

        default:
            break
        }
        
        return cell
    }
    
    // MARK: TextField Delegate Methods
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 551:
            userObj.userPassword = textField.text!
            self.passwordEdited = true;
            break
        case 552:
            userObj.userFName = textField.text!
            break
        case 553:
            userObj.userLName = textField.text!
            break
        case 554:
            userObj.userPhone = textField.text!
            break
        case 555:
            userObj.userLocation = textField.text!
            break
        case 556:
//            userObj.userLicenseLevel = textField.text!
            break
        default:
            userObj.userLicenseNumber = textField.text!
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == UIReturnKeyType.next {
            let kTextField = getViewWithTag(textField.tag+1, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString
        if textField.tag == 552 ||  textField.tag == 553 {
        if (str.length>30) {
            return false
        }
        } else if textField.tag == 554 {
            if (str.length>15) {
                return false
            }
        } else if textField.tag == 557 {
            if (str.length>15) {
                return false
            }
        }

        return true
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func profileImageButtonAction(_ sender: UIButton) {
          self.view .endEditing(true)
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.present(alert, animated: true, completion: nil)
//        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
          self.view .endEditing(true)
        isAllFieldVerified()
    }
    
    @IBAction func instructor(_ sender: UIButton) {
        instructorButton.isSelected = !instructorButton.isSelected
//        instructorButton.selected = true
//        driverButton.selected = false
        userObj.isDriver = true
    }
    
    @IBAction func driverButtonAction(_ sender: UIButton) {
        driverButton.isSelected = !driverButton.isSelected
//        driverButton.selected = true
//        instructorButton.selected = false
        userObj.isRegisteredDriver = true
    }
    
    //MARK:- Cell Button Action Methods
    func locationPickerButtonAction(_ sender: UIButton) {
        let locationPicker = LocationPickerViewController()
        
        let coordinates = CLLocationCoordinate2D(latitude: kAppDelegate.location.coordinate.latitude, longitude: kAppDelegate.location.coordinate.longitude)
        
        // you can optionally set initial location
        let initialLocation =  Location(name:kAppDelegate.currentAddress, location: kAppDelegate.location,
                                        placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
        locationPicker.location = initialLocation
        
        // button placed on right bottom corner
        locationPicker.showCurrentLocationButton = true // default: true
        
        // default: navigation bar's `barTintColor` or `.whiteColor()`
        locationPicker.currentLocationButtonBackground = .orange
        
        // ignored if initial location is given, shows that location instead
        locationPicker.showCurrentLocationInitially = true // default: true
        
        locationPicker.mapType = .standard // default: .Hybrid
        
        // for searching, see `MKLocalSearchRequest`'s `region` property
        locationPicker.useCurrentLocationAsHint = true // default: false
        
        locationPicker.searchBarPlaceholder = "Search places" // default: "Search or enter an address"
        
        locationPicker.searchHistoryLabel = "Previously searched" // default: "Search History"
        
        // optional region distance to be used for creation region when user selects place from search results
        locationPicker.resultRegionDistance = 500 // default: 600
        
        locationPicker.completion = { location in
        self.getAddressFromLocation((location?.location)!, completion: { (address:String?) in
        self.userObj.userLocation = address!
        self.editAccountTableView.reloadData()

                })
        }
        navigationController?.pushViewController(locationPicker, animated: true)
    }

    func getAddressFromLocation(_ loc : CLLocation,completion:@escaping (String?) -> Void) {
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                if let addressDic = pm.addressDictionary {
                    self.userObj.userCountry = addressDic["Country"] as? String ?? ""
                    self.userObj.userCity = addressDic["City"] as? String ?? ""
                    print(self.userObj.userCity  ,",",self.userObj.userCountry)
                    if let lines = addressDic["FormattedAddressLines"] as? [String] {
                        print(lines.joined(separator: ", "))
//                        completion(lines.joinWithSeparator(", "))
                        completion(String(format: "%@,%@", self.userObj.userCity  ,self.userObj.userCountry))
                    } else {
                        // fallback
                        if #available(iOS 9.0, *) {
                            completion (CNPostalAddressFormatter.string(from: self.postalAddressFromAddressDictionary(pm.addressDictionary! as! Dictionary<String, String>), style: .mailingAddress))
                        } else {
                            completion(ABCreateStringWithAddressDictionary(pm.addressDictionary!, false))
                        }
                    }
                } else {
                    completion ("\(self.location!.coordinate.latitude), \(self.location!.coordinate.longitude)")
                }
                
            } else {
                print("Problem with the data received from geocoder")
                return
            }
        })
    }
    
    @available(iOS 9.0, *)
    func postalAddressFromAddressDictionary(_ addressdictionary: Dictionary<String,String>) -> CNMutablePostalAddress {
        
        let address = CNMutablePostalAddress()
        
//        address.street = addressdictionary["Street"] as? String ?? ""
//        address.state = addressdictionary["State"] as? String ?? ""
        address.city = addressdictionary["City"] ?? ""
        address.country = addressdictionary["Country"] ?? ""
        //address.postalCode = addressdictionary["ZIP"] as? String ?? ""
        userObj.userCity = address.city
        userObj.userCountry = address.country
        
        return address
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForUpdateUserProfile() {
        
        if(passwordEdited) {
            userObj.userPasswordHash = userObj.userPassword.md5()
        }
        else {
            userObj.userPasswordHash = UserDefaults.standard.value(forKey: "wheelzUserPassword") as! String
        }
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict["userName"] = userObj.userEmail
        paramDict[WUserPassword] = userObj.userPasswordHash
        paramDict[WUserFName] = userObj.userFName
        paramDict[WUserLName] = userObj.userLName
        paramDict[WUserCity ] = userObj.userCity
        paramDict[WUserCountry] = userObj.userCountry
        paramDict[WBase64Pic] = self.imageData != nil ? self.imageData.base64EncodedString() : ""
        paramDict[WUserPic] = paramDict.value(forKey: WBase64Pic) as! String
           != "" ? "" : userObj.userImageFileName
        paramDict[WUserInstructor] = userObj.isRegisteredDriver
        paramDict[WUserLicenseLevel] = userObj.userLicenseLevel
        paramDict[WUserLicenseNumber] = userObj.userLicenseNumber
        paramDict[WUserDriver] = userObj.isDriver
        paramDict[WUserPhoneNumber] = userObj.userPhone

        let apiNameUpdateUser = kAPINameUpdateUser()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUpdateUser, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    } else {
                                self.navigationController?.popViewController(animated: true)

                        //                        dispatch_async(dispatch_get_main_queue()) {
                        //                            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                        //                        }
                    }
                }
            }
            
        }
    }

}

