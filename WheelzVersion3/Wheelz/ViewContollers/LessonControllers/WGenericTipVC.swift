//
//  WGenericTipVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2017-05-27.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WGenericTipVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = UIApplication.shared.currentUserNotificationSettings
        
        //if settings are not initialized or Alert notification type is not permitted, ask for PN permissions
        if (settings == nil || !settings!.types.contains(.alert))
        {
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

