//
//  WEditLessonVC.swift
//  Wheelz
//
//  Created by Neha Chhabra on 05/09/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts
import AddressBookUI

class WEditLessonVC: UIViewController, UIPickerViewDelegate {

    var regularDriverRate : Double = 0.0
    var instructorRate : Double = 0.0
    var shareRate : Double = 0.0

     var lessonObj : WLessonInfo!
    var location: Location? {
        didSet {
            //            locationNameLabel.text = location.flatMap({ $0.title }) ?? "No location selected"
        }
    }
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var locationtextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: Window_Height-184, width: Window_Width, height: 184))
    let durationTimePicker = UIDatePicker(frame: CGRect(x: 0, y: Window_Height-184, width: Window_Width, height: 184))
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //MARK:- Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Helper Methods
    func customInit() {
        self.navigationItem.title = "Edit Your Lesson"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("backArrow", controller: self)// self.backBarBackButton("backArrow")
        if Window_Width > 320  {
            scrollView.isScrollEnabled = false
        }
        
        priceLabel.text = String(format:"$%.0f", self.lessonObj.lessonAmount)
        dateTextField.text = self.getDateFromTimeStamp(lessonObj.lessonTimestamp)
        //        locationtextField.text = lessonObj!.lesso
        durationTextField.text =  self.getExactTime( String(format: "0%.2f",lessonObj.lessonDuration))
        
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date().addingTimeInterval(86400*30)
        durationTimePicker.datePickerMode = .countDownTimer
        datePicker.addTarget(self, action: #selector(WEditLessonVC.onDidChangeDate(_:)), for: .valueChanged)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = addToolBar("Next", btnTag: 500)
        durationTimePicker.minuteInterval = 15
        durationTimePicker.addTarget(self, action: #selector(WEditLessonVC.durationPickerMethod(_:)), for: .valueChanged)
        durationTextField.inputView = durationTimePicker
        durationTextField.inputAccessoryView = addToolBar("Done", btnTag: 502)
        let locationCoordinate = CLLocation(latitude: lessonObj.locLat, longitude: lessonObj.locLon)
        self.getAddressFromLocation((locationCoordinate), completion: { (address:String?) in
            self.locationtextField.text = address
        })
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        self.dismiss(animated: true, completion: {
            //
        })
    }

    internal func onDidChangeDate(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:mm"
        lessonObj.lessonTimestamp = (sender.date).timeIntervalSince1970
        lessonObj.lessonDateTime = sender.date
        print(lessonObj.lessonDateTime)
        print(lessonObj.lessonTimestamp)
        let strDate = dateFormatter.string(from: sender.date)
        dateTextField.text =  strDate
    }

    func durationPickerMethod(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        var strDate = dateFormatter.string(from: sender.date)
        let arrStr = strDate.components(separatedBy: ":")
        
        if (arrStr.first! == "12" && arrStr.last! == "15")  {
            AlertController.alert("", message: "Lesson must be at least 30 minutes long.")
        } else if ((strDate.replacingOccurrences(of: ":", with: ".") as NSString).doubleValue > 5 && arrStr.first! != "12") {
            AlertController.alert("", message: "Maximum lesson duration is 5 hours.")
        } else {
            strDate = strDate.replacingOccurrences(of: "12", with: "00")
            durationTextField.text = strDate

            strDate = strDate.replacingOccurrences(of: "15", with: "25")
            strDate = strDate.replacingOccurrences(of: "30", with: "50")
            strDate = strDate.replacingOccurrences(of: "45", with: "75")
            strDate = (strDate.replacingOccurrences(of: ":", with: ".") as NSString) as String
            print(durationTextField.text )
            lessonObj.lessonDuration = (strDate as NSString).doubleValue
        }
        print(lessonObj.lessonDuration)
    }

    func  addToolBar(_ name:String, btnTag : NSInteger) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height - 46, width: Window_Width, height: 46)
        let nextButton = UIBarButtonItem(title:name, style: UIBarButtonItemStyle.plain, target: self, action: #selector(nextBarButtonAction(_:)))
        //        let spaceButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        nextButton.tag = btnTag
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),nextButton]
        toolbar.sizeToFit()
        toolbar.backgroundColor = UIColor.lightGray
        toolbar.setItems(toolbarItems, animated: false)
        return toolbar
    }
    
    @objc func nextBarButtonAction(_ button : UIButton) {
        if button.tag == 500 {
                self.view.endEditing(true)
                self.locationMethod()
        } else if button.tag == 501  {
//            let kTextField = getViewWithTag(button.tag+1, view: self.view) as? UITextField
//            kTextField?.becomeFirstResponder()
        } else {
          self.view.endEditing(true)
            self.callAPIForGetRates()
        }
       
    }

    func getDateFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func getExactTime(_ value : String) -> String {
        var strDate =  value.replacingOccurrences(of: ".", with: ":")
        strDate = strDate.replacingOccurrences(of: "25", with: "15")
        strDate = strDate.replacingOccurrences(of: "50", with: "30")
        strDate = strDate.replacingOccurrences(of: "75", with: "45")

        return strDate
    }

    fileprivate func isAllFieldVerified() ->Bool {
        
        var fieldVerified: Bool = false
        
        if (self.dateTextField.text!.trimWhiteSpace().length == 0) {
            //alertLabel.text = "Please enter email address"
            presentAlert("", msgStr: "Please select date.", controller: self)
        }  else if (self.locationtextField.text!.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please select location.", controller: self)
        } else if (self.durationTextField.text?.trimWhiteSpace().length == 0) {
            presentAlert("", msgStr: "Please select duration.", controller: self)
        }else {
            fieldVerified = true
        }
        return fieldVerified
    }

    func locationMethod()  {
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
                self.locationtextField.text = address
            })
        }
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    func setFareAmount() {
        if lessonObj.isInstructorRequired {
            print(lessonObj.lessonDuration)
            print(instructorRate)
            print(regularDriverRate)
            priceLabel.text = String(format:"$%.0f",lessonObj.lessonDuration *  instructorRate)
            lessonObj.lessonAmount = lessonObj.lessonDuration * instructorRate
        } else {
            print(lessonObj.lessonDuration)
            print(instructorRate)
            print(regularDriverRate)
            print(String(format:"$%.0f",lessonObj.lessonDuration *  regularDriverRate))
            priceLabel.text = String(format:"$%.0f",lessonObj.lessonDuration *  regularDriverRate)
            lessonObj.lessonAmount = lessonObj.lessonDuration * regularDriverRate
        }
    }
    
    // MARK: TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 500:
//            pickerOption = 0
            break
        case 501:
            self.view.endEditing(true)
            locationMethod()
            break
        case 502:
//            pickerOption = 2
            break
        default:
            break
        }
       
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch (textField.tag) {
        case 500:
            lessonObj!.lessonDate = textField.text!
            break
        case 501:
            break
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var str:NSString = textField.text! as NSString
        str = str.replacingCharacters(in: range, with: string) as NSString

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.next {
            let kTextField = getViewWithTag(textField.tag+1, view: self.view) as? UITextField
            kTextField?.becomeFirstResponder()
        } else {
            self.view .endEditing(true)
        }
        return true
    }
    
    func getAddressFromLocation(_ loc : CLLocation,completion:@escaping (String?) -> Void) {
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.lessonObj.locLat = loc.coordinate.latitude
                self.lessonObj.locLon = loc.coordinate.longitude
                if let addressDic = pm.addressDictionary {
                    if let lines = addressDic["FormattedAddressLines"] as? [String] {
                        completion(lines.joined(separator: ", "))
                    } else {
                        // fallback
                        if #available(iOS 9.0, *) {
                            completion (CNPostalAddressFormatter.string(from: self.postalAddressFromAddressDictionary(pm.addressDictionary! as! Dictionary<String, String>), style: .mailingAddress))
                        } else {
                            completion(ABCreateStringWithAddressDictionary(pm.addressDictionary!, false))
                        }
                    }
                } else {
                    completion ("\(self.location?.coordinate.latitude), \(self.location?.coordinate.longitude)")
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
        
        address.street = addressdictionary["Street"] ?? ""
        address.state = addressdictionary["State"] ?? ""
        address.city = addressdictionary["City"] ?? ""
        address.country = addressdictionary["Country"] ?? ""
        address.postalCode = addressdictionary["ZIP"] ?? ""
        
        return address
    }
    
    //MARK:- UIButton Action Methods
    @IBAction func updateButtonAction(_ sender: UIButton) {
        self.callAPIForUpdateLessons()
    }
    
    
    //MARK:- Web API Methods
    fileprivate func callAPIForUpdateLessons() {
        
        let paramDict = NSMutableDictionary()
        paramDict[WLessonID] = lessonObj.lessonID
        paramDict[WDateTime] = String(format: "%@", Date(timeIntervalSince1970: lessonObj.lessonTimestamp) as CVarArg)
        paramDict[WLongitude] = lessonObj.locLon
        paramDict[WLatitude] = lessonObj.locLat
        paramDict[WDuration] = lessonObj.lessonDuration
        paramDict[WInstructorRequired] = lessonObj.isInstructorRequired
        paramDict[WUTCDateTime] = lessonObj.lessonTimestamp
        paramDict[WAmount] = lessonObj.lessonAmount
        let apiNameUpdateLesson = kAPINameUpdateLesson()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUpdateLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil ) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message != "" {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                            }
                        })
                    } else {
                        self.navigationController?.popViewController(animated: true)
                        
                        //                        dispatch_async(dispatch_get_main_queue()) {
                        //                            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                        //                        }
                    }
                } else {
//                    self.navigationController?.popViewControllerAnimated(true)
                    self.dismiss(animated: true, completion: {
                        //
                    })
                }
            }
            
        }
    }

    fileprivate func callAPIForGetRates() {
        
        let paramDict = NSMutableDictionary()
        let apiNameGetRates = kAPINameGetRates()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetRates, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "Message") as? String ?? ""
                    if message == "" {
                        self.regularDriverRate = responseObject?.object(forKey: "regularDriver") as? Double ?? 0.0
                        self.instructorRate =  responseObject?.object(forKey: "instructor") as? Double ?? 0.0
                        self.shareRate =  responseObject?.object(forKey: "share") as? Double ?? 0.0
                        self.setFareAmount()
                    } else  {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                                // do nothing
                            }
                        })
                    }
                }
            }
        }
    }
}
