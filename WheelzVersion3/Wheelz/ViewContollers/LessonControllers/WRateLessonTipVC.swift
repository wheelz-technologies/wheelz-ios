//
//  WRateLessonTipVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2017-01-06.
//  Copyright © 2017 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WRateLessonTipVC: UIViewController {

    @IBOutlet weak var tipTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            tipTextLabel.text = "Make sure to rate your experience - it directly affects your student's profile. Good luck!"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
