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
            tipText.text = "We'll remind you to show up on time!"
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