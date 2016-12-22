//
//  WSelectDateVC.swift
//  Wheelz
//
//  Created by Neha Chhabra on 04/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts
import AddressBookUI
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
    
    let lessonInfo = WLessonInfo()
    
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
        lessonInfo.lessonDuration = 0.50
        lessonInfo.lessonTimestamp = Date().timeIntervalSince1970
        //durationLabel.text = "Select Lesson Interval : 00hour : 30mins"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY, HH:mm"
        //        let strDate = dateFormatter.stringFromDate(NSDate())
        //dateTimeLabel.text = "Select Date and Time : " + strDate
        dateFormatter.dateFormat =  "HH:mm"
        
        let calendar = NSCalendar.current
        let twoHoursFromNow = calendar.date(byAdding: Calendar.Component.hour, value: 2, to: Date())
        dateTimePicker.setDate(twoHoursFromNow!, animated: true)
        lessonInfo.lessonDateTime = twoHoursFromNow!
        lessonInfo.lessonTimestamp = (twoHoursFromNow!).timeIntervalSince1970
        
        let date = dateFormatter.date(from: "00:30")
        
        durationTimePicker.setDate(date!, animated: true)
        //        self.setNavigationBarTitleText((self.navigationController?.navigationBar)!)
        self.navigationItem.title = "Date and Location"
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
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
            return
        } else if (!(arrStr.first! == "12") && (strDate.replacingOccurrences(of: ":", with: ".") as NSString).doubleValue > 5) {
            //AlertController.alert("Lesson Duration", message: "Maximum lesson duration is 5 hours.")
            presentFancyAlert("Lesson Duration", msgStr: "Maximum lesson duration is 5 hours.", type: AlertStyle.Info, controller: self)
            self.durationTimePicker.setDate(dateFormatter.date(from: "05:00")!, animated: true)
            return
        } else {
            strDate = strDate.replacingOccurrences(of: "12", with: "00")
            strDate = strDate.replacingOccurrences(of: "15", with: "25")
            strDate = strDate.replacingOccurrences(of: "30", with: "50")
            strDate = strDate.replacingOccurrences(of: "45", with: "75")
            lessonInfo.lessonDuration = (strDate.replacingOccurrences(of: ":", with: ".") as NSString).doubleValue
            print(lessonInfo.lessonDuration)
            //durationLabel.text = NSString(format: "Select Lesson Interval : %@%@ : %@mins", arrStr.first! == "12" ? "00" : arrStr.first!,arrStr.first! == "01" ? "hour" : "hours",arrStr.last!) as String
        }
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if  ((self.placeTextField.text?.length) > 0) {
            let instructorVC = self.storyboard?.instantiateViewController(withIdentifier: "WNeedInstructorVCID")as! WNeedInstructorVC
            instructorVC.lessonObj = lessonInfo
            self.navigationController?.pushViewController(instructorVC, animated: true)
        } else {
            //AlertController.alert("",message: "Please select pickup location.")
            presentFancyAlert("Pickup Location", msgStr: "Please select pickup location.", type: AlertStyle.Info, controller: self)
        }
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
