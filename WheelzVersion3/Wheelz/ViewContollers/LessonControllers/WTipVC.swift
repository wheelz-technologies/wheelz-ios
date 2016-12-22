//
//  WTipViewController.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-15.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WTipVC: UIViewController {
    
    @IBOutlet weak var tipImage: UIImageView!
    @IBOutlet weak var tipText: UILabel!
    @IBOutlet weak var tipBtn: WCustomButton!
    var isDriver = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isDriver) {
            tipText.text = "Setup your payments and start driving!"
            self.tipBtn.setTitle("SET UP NOW", for: UIControlState())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tipButtonAction(_ sender: AnyObject) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        self.dismiss(animated: true, completion: nil)
        
        if(isDriver) {
            let paymentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WDriverPaymentsVCID") as! WDriverPaymentsVC
            
            drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
            drawerController.setDrawerState(.closed, animated: true)
        } else {
            let paymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WPaymentsVCID") as! WPaymentsVC
            
            drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
            drawerController.setDrawerState(.closed, animated: true)

        }
    }
    
}
