//
//  WDriverPaymentsVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-10-05.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import Stripe

class WDriverPaymentsVC: UIViewController,UIGestureRecognizerDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var setupButton: WCustomButton!
    var statusDetailsObj = WPaymentSetupDetails()
    
    // MARK: - UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Payments"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        callAPIForPaymentSetupDetails()
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    // MARK: UIButton Action Methods
    
    @IBAction func setupButtonAction(_ sender: AnyObject) {
        let setupPaymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WSetupDriverPaymentsVCID") as! WSetupDriverPaymentsVC
        self.navigationController?.pushViewController(setupPaymentsVC, animated: true)
    }
    
    // MARK: - Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Web API Section
    fileprivate func callAPIForPaymentSetupDetails() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetSetupDetails = kAPINameGetSetupDetails((UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetSetupDetails, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
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
                            self.statusDetailsObj = WPaymentSetupDetails.getPaymentSetupDetails(responseObject!)
                        
                        switch self.statusDetailsObj.status {
                        case "unverified":
                            if(self.statusDetailsObj.details == "identity document required") {
                                self.titleLabel.text = "Your payments are set up."
                                self.detailsLabel.text = "We might ask for additional information later, but for now you're good to go!"
                                self.setupButton.isHidden = true;
                            } else if (self.statusDetailsObj.details == "additional information required") {
                                self.titleLabel.text = "Your payments are not set up."
                                self.detailsLabel.text = "We need some additional information. Please, contact us for details."
                                self.setupButton.isHidden = true;
                            }
                            break
                        case "pending":
                            self.titleLabel.text = "We are reviewing your details."
                            self.detailsLabel.text = "You can start claiming lessons in the meantime. You'll receive payment as soon as we finish."
                            self.setupButton.isHidden = true;
                            break
                        case "verified":
                            self.titleLabel.text = "Your payments are set up."
                            self.detailsLabel.text = "We have confirmed your information and will deposit payments directly into your account."
                            self.setupButton.isHidden = true;
                            break
                        default:
                            self.titleLabel.text = "Payment set up failed."
                            self.detailsLabel.text = "We had an issue while reviewing your information. Please, contact us for details."
                            self.setupButton.setTitle("TRY AGAIN", for: UIControlState())
                            break
                        }
                    }
                }
            }
        }
    }
}
