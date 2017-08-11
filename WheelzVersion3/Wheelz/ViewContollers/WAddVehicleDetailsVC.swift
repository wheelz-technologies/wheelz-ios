//
//  WAddVehicleDetailsVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2017-02-08.
//  Copyright © 2017 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WAddVehicleDetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var vehicleImageView: UIImageView!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var manualTransBtn: UIButton!
    @IBOutlet weak var autoTransBtn: UIButton!
    @IBOutlet weak var vehicleAddUpdateBtn: WCustomButton!
    
    var vehicleObj : WVehiclesInfo!
    var isFirstTime = false //equals True only if adding vehicle during driver registration
    var isUpdateVehicle = Bool()
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popover:UIPopoverController? = nil
    var imageData : Data!
    var imageUploaded = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Helper Methods
    fileprivate func customInit() {
        self.navigationItem.leftBarButtonItem = self.backBarBackButton("backArrow")
        
        if isUpdateVehicle == true {
            vehicleImageView.setImageWithUrl(URL(string: vehicleObj.carImage)!, placeHolderImage: UIImage(named: "carPic.png"))
            
            if(vehicleObj.transType == "Manual") {
                manualTransBtn.backgroundColor = kAppOrangeColor
            } else {
                autoTransBtn.backgroundColor = kAppOrangeColor
            }
            vehicleAddUpdateBtn.setTitle("UPDATE VEHICLE", for: UIControlState())
            self.navigationItem.title = "Edit Vehicle"
        } else {
            vehicleAddUpdateBtn.setTitle("ADD VEHICLE", for: UIControlState())
            self.navigationItem.title = "Add Vehicle"
        }
        
        vehicleLabel.text = "Your \(vehicleObj.year) \(vehicleObj.make) \(vehicleObj.model)"
    }
    
    @IBAction func vehicleImageTapAction(_ sender: Any) {
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
        
        //>>>>>>>>>>>>>>>>>>>>> Dead code; As project is for iPhone only, "else" will never get executed
        // Present the actionsheet
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(alert, animated: true, completion: nil)
        } else {
            popover=UIPopoverController(contentViewController: alert)
            popover!.present(from: vehicleImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
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
        } else {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.present(from: vehicleImageView.frame, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker .dismiss(animated: true, completion: {
            self.vehicleImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            UIView.animate(withDuration: 4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 7.0, options: UIViewAnimationOptions(), animations: ({
                self.imageUploaded = true;
                self.view.layoutSubviews()
            }), completion: nil)
        })
        self.imageData = Data()
        self.imageData = UIImageJPEGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage!)!,0.2)!
    }
    
    @IBAction func manualTransBtnAction(_ sender: UIButton) {
        self.vehicleObj.transType = "Manual"
        sender.backgroundColor = kAppOrangeColor
        autoTransBtn.backgroundColor = UIColor.clear
    }
    
    @IBAction func automaticTransBtnAction(_ sender: UIButton){
        self.vehicleObj.transType = "Auto"
        sender.backgroundColor = kAppOrangeColor
        manualTransBtn.backgroundColor = UIColor.clear
    }
    
    @IBAction func addVehicleBtnAction(_ sender: Any) {
        self.view.endEditing(true)
        
        if(vehicleObj.transType.isEmpty)
        {
            presentFancyAlert("Whoops!", msgStr: "Please select a transmission type.", type: AlertStyle.Info, controller: self)
        } else {
            if isUpdateVehicle {
                callAPIForUpdateVehicle(vehicleObj.vehicleId)
            } else {
                callAPIForCreateNewVehicle()
            }
        }
    }
    
    // MARK : Web API section
    fileprivate func callAPIForCreateNewVehicle() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WMake] = vehicleObj!.make
        paramDict[WModel] = vehicleObj!.model
        paramDict[WYear] = vehicleObj!.year
        paramDict[WVin] = vehicleObj!.vin
        paramDict[WAvailableForTest] = vehicleObj!.isAvailableForTest
        paramDict[WTransmissionType] = vehicleObj!.transType
        paramDict[WUserPic] =  ""
        paramDict[WBase64Pic] = self.imageData != nil ? self.imageData.base64EncodedString() : ""
        paramDict[WIsMain] = vehicleObj!.isMain
        
        let apiNameCreateNewVehicle = kAPINameCreateNewVehicle()
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .post, apiName: apiNameCreateNewVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    
                    if(self.isFirstTime) {
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(kAppDelegate.addSidePanel(), animated: false)
                            let tipVc = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                            tipVc.orderedViewControllers = [newViewControllerFromMain(name: "WSignUpTipVCID"),
                                                            newViewControllerFromMain(name: "WDriverSignUpTip1VCID"),
                                                            newViewControllerFromMain(name: "WLessonTypesVCID"),
                                                            newViewControllerFromMain(name: "WDriverSignUpTip2VCID"),
                                                            newViewControllerFromMain(name: "WDriverLessonTip1VCID"),
                                                            newViewControllerFromMain(name: "WDriverSignUpTip3VCID")]
                            
                            kAppDelegate.window?.rootViewController!.present(tipVc, animated: true, completion: nil)
                        }
                    }
                    else{
                        self.navigationController?.popToRootViewController(animated: true)
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
        paramDict[WAvailableForTest] = vehicleObj!.isAvailableForTest
        paramDict[WTransmissionType] = vehicleObj!.transType
        paramDict[WBase64Pic] = self.imageData != nil ? self.imageData.base64EncodedString() : ""
        paramDict[WUserPic] = self.imageData != nil ? "" : vehicleObj!.carImageFileName
        paramDict[WIsMain] = vehicleObj!.isMain
        let apiNameUpdateVehicle = kAPINameUpdateVehicle()
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameUpdateVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}
