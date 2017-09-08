//
//  WHelpVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WHelpVC: UIViewController {
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customInit()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.navigationItem.title = "Help"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        
//        let navBar: UINavigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64));       self.view.addSubview(navBar)
//        let navItem = UINavigationItem(title: "Help")
//        navItem.leftBarButtonItem = self.backBarBackButton("backArrow")
//        navBar.setItems([navItem], animated: false)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
}
