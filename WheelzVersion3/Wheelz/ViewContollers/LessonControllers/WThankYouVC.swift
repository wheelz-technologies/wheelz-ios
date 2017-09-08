//
//  WThankYouVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-11-26.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit
import Social

class WThankYouVC: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image : UIImage = UIImage(named: "fenderLogoWhite.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 70))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated:true);

        let userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? ""
        let promoCode = generatePromoCode(length: 9) //Promo Code is 8 alphanumeric characters long
            
        let apiNameAddPromoCode = kAPINameAddPromoCode(userId, code: promoCode)
            
        ServiceHelper.sharedInstance.callAPIWithParameters(NSMutableDictionary(), method: .post, apiName:apiNameAddPromoCode, hudType: .noProgress) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
                
            if error != nil {
                    return
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                        if message == "Created" {
                            
                            //promo code created                
                            self.mainLabel.text = promoCode
                            self.subtitleLabel.text = "Use this Promo Code or share with a friend for a discount!"
                            
                        } else  {
                            //not so much :(
                            return
                        }
                    }
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func twitterBtnAction(_ sender: Any) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            
            let tweetShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.setInitialText("I've aced my driving lesson with Fender! #LearnWheelz with me: https://appstore.re/ca/NKHBhb.i")
            
            self.present(tweetShare, animated: true, completion: nil)
            
        } else {
           presentFancyAlert("Tweet", msgStr: "Please login to your Twitter account to tweet.", type: AlertStyle.Info, controller: self)
        }
    }
    
    @IBAction func facebookBtnAction(_ sender: Any) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbShare: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText("I've aced my driving lesson with Fender! #LearnWheelz with me: https://appstore.re/ca/NKHBhb.i")
            
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
    
    func generatePromoCode(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
