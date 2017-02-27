//
//  WThankYouVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-26.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import Social

class WThankYouVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Wheelz"
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func twitterBtnAction(_ sender: Any) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let tweetShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.setInitialText("I've aced my driving lesson with Wheelz! #LearnWheelz with me: https://appstore.re/ca/NKHBhb.i")
            
            self.present(tweetShare, animated: true, completion: nil)
            
        } else {
           presentFancyAlert("Tweet", msgStr: "Please login to your Twitter account to tweet.", type: AlertStyle.Info, controller: self)
        }
    }
    
    @IBAction func facebookBtnAction(_ sender: Any) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText("I've aced my driving lesson with Wheelz! #LearnWheelz with me: https://appstore.re/ca/NKHBhb.i")
            
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            presentFancyAlert("Share", msgStr: "Please login to your Facebook account to share.", type: AlertStyle.Info, controller: self)
        }
    }
    
    
    @IBAction func backToMapButtonAction(_ sender: Any) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        
        self.dismiss(animated: true, completion: nil)
        
        drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
        drawerController.setDrawerState(.closed, animated: true)
    }
}
