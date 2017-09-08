//
//  WTipDriverPaymentsVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2017-01-03.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WTipDriverPaymentsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func setupBtnAction(_ sender: Any) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        let paymentsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WDriverPaymentsVCID") as! WDriverPaymentsVC
        
        self.dismiss(animated: true, completion: nil)
        
        drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
        drawerController.setDrawerState(.closed, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        
        self.dismiss(animated: true, completion: nil)
        
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        drawerController.setDrawerState(.closed, animated: true)
    }
}
