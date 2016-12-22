//
//  WMapTipVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-12-16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WMapTipVC: UIViewController {

    @IBOutlet weak var blueIconLabel: UILabel!
    @IBOutlet weak var greenIconLabel: UILabel!
    @IBOutlet weak var greenIcon: UIImageView!
    @IBOutlet weak var requestLessonLabel: UILabel!
    @IBOutlet weak var requestLessonArrow: UIImageView!
    
    var isDriver = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(isDriver) {
            requestLessonLabel.isHidden = true
            requestLessonArrow.isHidden = true
        } else {
            blueIconLabel.text = "Lessons, already claimed by a driver."
            greenIconLabel.isHidden = true
            greenIcon.isHidden = true
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