//
//  WLessonTipVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-15.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WLessonTipVC: UIViewController {
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipText: UILabel!

    var isDriver = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isDriver) {
            tipLabel.text = "You claimed a lesson."
            tipText.text = "We'll let you know when a student confirms!"
        }
        
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        //if settings are not initialized or Alert notification type is not permitted, ask for PN permissions
        if (settings == nil || !settings!.types.contains(.alert))
        {
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            
            //presentFancyAlert("Notifications", msgStr: "Consider enabling Notifications in Device Settings, so we can send you updates about your lessons.", type: AlertStyle.Info, controller: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil)
    }
}
