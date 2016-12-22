//
//  WAlertsControllerVC.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WAlertsVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var alertsArray = NSMutableArray()
    @IBOutlet weak var alertTableView: UITableView!
    
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
        alertsArray = ["alert1: Hey arseniy you got first alert","alert2: Hey arseniy you got a second dynamic height alert", "alert3: layout working fine now"] //test values

        self.alertTableView.estimatedRowHeight = 60
        self.alertTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Alerts"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    func getDateFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WAlertTVCellID", for: indexPath) as! WAlertTVCell
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? RGBA(255, g: 245, b: 245, a: 1) : RGBA(255, g: 255, b: 255, a: 1)
        cell.alertInfoLabel.text  = alertsArray .object(at: indexPath.row) as? String
        cell.alertDateLabel.text = getDateFromTimeStamp(Date().timeIntervalSince1970)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
