//
//  WSelectDateVC.swift
//  Fender
//
//  Created by Neha Chhabra on 04/08/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts
import AddressBookUI
import SCLAlertView

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


class WSelectDateVC: UIViewController {
    @IBOutlet var dateTimeLabel: UILabel!
    @IBOutlet var dateTimePicker: UIDatePicker!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var durationTimePicker: UIDatePicker!
    @IBOutlet var placeTextField: UITextField!
    
    var lessonInfo = WLessonInfo()
    var promoCode = ""
    var isEdit = false
    
    var location: Location? {
        didSet {
            //            locationNameLabel.text = location.flatMap({ $0.title }) ?? "No location selected"
        }
    }
    
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
        dateTimePicker.minimumDate = Date()
        dateTimePicker.maximumDate = Date().addingTimeInterval(86400*30)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:mm"
        dateFormatter.dateFormat =  "HH:mm"
        let calendar = NSCalendar.current
        let date = dateFormatter.date(from: "00:30")
        
        self.navigationItem.title = "Date and Location"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
        if(isEdit) {
            let lessonDate = Date(timeIntervalSince1970: lessonInfo.lessonTimestamp)
            let dateString = getExactTime( String(format: "0%.2f",lessonInfo.lessonDuration))
            dateTimePicker.setDate(lessonDate, animated: true)
            durationTimePicker.setDate(dateFormatter.date(from: dateString)!, animated: true)
            
            let coordinates = CLLocationCoordinate2D(latitude: kAppDelegate.location.coordinate.latitude, longitude: kAppDelegate.location.coordinate.longitude)
            
            let lessonLoc = CLLocation(latitude: lessonInfo.locLat, longitude: lessonInfo.locLon)
            self.location = Location(name: "", location: lessonLoc,
                                          placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
        } else {
            lessonInfo.lessonDuration = 0.50
            lessonInfo.lessonTimestamp = Date().timeIntervalSince1970
            
            let twoHoursFromNow = calendar.date(byAdding: Calendar.Component.hour, value: 2, to: Date())
            dateTimePicker.setDate(twoHoursFromNow!, animated: true)
            lessonInfo.lessonDateTime = twoHoursFromNow!
            lessonInfo.lessonTimestamp = (twoHoursFromNow!).timeIntervalSince1970
        
            durationTimePicker.setDate(date!, animated: true)
        }
        
        if(location != nil) {
            self.getAddressFromLocation((location?.location)!, completion: { (address:String?) in
                self.placeTextField.text = address
                self.location?.name = address
            })
        }
    }
    
    @IBAction func locationPickerButtonAction(_ sender: UIButton) {
        let locationPicker = setupLocationPicker()

        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func dateTimePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:mm"
        lessonInfo.lessonTimestamp = (sender.date).timeIntervalSince1970
        lessonInfo.lessonDateTime = sender.date
    }
    
    @IBAction func durationPicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        var strDate = dateFormatter.string(from: sender.date)
        let arrStr = strDate.components(separatedBy: ":")
        
        if (arrStr.first! == "12" && arrStr.last! == "15")  {
            //AlertController.alert("Lesson Duration", message: "Lesson must be at least 30 minutes long.")
            presentFancyAlert("Lesson Duration", msgStr: "Lesson must be at least 30 minutes long.", type: AlertStyle.Info, controller: self)
            self.durationTimePicker.setDate(dateFormatter.date(from: "00:30")!, animated: true)
            lessonInfo.lessonDuration = ("00.50" as NSString).doubleValue
            return
        } else if (!(arrStr.first! == "12") && (strDate.replacingOccurrences(of: ":", with: ".") as NSString).doubleValue > 5) {
            //AlertController.alert("Lesson Duration", message: "Maximum lesson duration is 5 hours.")
            presentFancyAlert("Lesson Duration", msgStr: "Maximum lesson duration is 5 hours.", type: AlertStyle.Info, controller: self)
            self.durationTimePicker.setDate(dateFormatter.date(from: "05:00")!, animated: true)
            lessonInfo.lessonDuration = ("05.00" as NSString).doubleValue
            return
        } else {
            strDate = strDate.replacingOccurrences(of: "12", with: "00")
            strDate = strDate.replacingOccurrences(of: "15", with: "25")
            strDate = strDate.replacingOccurrences(of: "30", with: "50")
            strDate = strDate.replacingOccurrences(of: "45", with: "75")
        }
        
        lessonInfo.lessonDuration = (strDate.replacingOccurrences(of: ":", with: ".") as NSString).doubleValue
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if  ((self.placeTextField.text?.length) > 0) {
            /*let instructorVC = self.storyboard?.instantiateViewController(withIdentifier: "WNeedInstructorVCID")as! WNeedInstructorVC
            instructorVC.lessonObj = lessonInfo
            instructorVC.isEdit = self.isEdit
            self.navigationController?.pushViewController(instructorVC, animated: true)*/
            
            if(self.lessonInfo.promoCodeID.isEmpty) {
            
            DispatchQueue.main.async {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                
                let alert = SCLAlertView(appearance: appearance)
                alert.modalPresentationStyle = .overCurrentContext
                alert.view.layer.zPosition = 1
                let promoCodeInput = alert.addTextField("Enter promo code")
                
                alert.addButton("Add") {
                    self.promoCode = promoCodeInput.text ?? ""
                    
                    if(self.promoCode.isEmpty) {
                        promoCodeInput.setBorder(kAppOrangeColor, borderWidth: 2.0)
                        return
                    }
                    
                    // Promo Code logic
                    let userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
                    
                    let apiNameGetPromoCode = kAPINameGetPromoCode(userId ?? "", code: self.promoCode)
                    
                    ServiceHelper.sharedInstance.callAPIWithParameters(NSMutableDictionary(), method: .get, apiName: apiNameGetPromoCode, hudType: .smoothProgress) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
                        
                        if error != nil {
                            promoCodeInput.setBorder(kAppOrangeColor, borderWidth: 2.0)
                            return
                        } else {
                            if (responseObject != nil) {
                                // apply promo code to lesson and proceed
                                self.lessonInfo.promoCodeID = responseObject!.object(forKey: "promoCodeId") as? String ?? ""
                                }
                                self.nextStep()
                            }
                        }
                    }
                
                    alert.addButton("Skip") {
                        // skip Promo Code logic
                        self.nextStep()
                    }
                
                    alert.showEdit(
                        "Add Promo Code",
                        subTitle: "Got a promo code? Use it for a discount!",
                        closeButtonTitle: "Skip",
                        colorStyle: 185514,
                        colorTextButton: 0xFFFFFF)
                }
            } else {
            //lesson already has a promo code applied
            self.nextStep()
        }
        } else {
            //AlertController.alert("",message: "Please select pickup location.")
            presentFancyAlert("Pickup Location", msgStr: "Please select pickup location.", type: AlertStyle.Info, controller: self)
        }
    }
    
    func nextStep() {
        let lessonTypeVC = self.storyboard?.instantiateViewController(withIdentifier: "WSelectSkillVCID") as! WSelectSkillVC
        lessonTypeVC.lessonObj = lessonInfo
        lessonTypeVC.isEdit = self.isEdit
        self.navigationController?.pushViewController(lessonTypeVC, animated: true)
    }
    
    func setupLocationPicker() -> LocationPickerViewController {
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
                self.placeTextField.text = address
            })
        }
        
        return locationPicker
    }
    
    func getAddressFromLocation(_ loc : CLLocation,completion:@escaping (String?) -> Void) {
        
        CLGeocoder().reverseGeocodeLocation(loc, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.lessonInfo.locLat = loc.coordinate.latitude
                self.lessonInfo.locLon = loc.coordinate.longitude
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
    
}
