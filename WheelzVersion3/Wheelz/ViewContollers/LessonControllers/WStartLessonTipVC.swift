//
//  WStartLessonTipVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2017-01-06.
//  Copyright © 2017 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WStartLessonTipVC: UIViewController {

    @IBOutlet weak var tipTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            tipTextLabel.text = "Tap the Start Lesson button on Lesson Detail screen when you're ready. Your student will do the same."
        }
        
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
