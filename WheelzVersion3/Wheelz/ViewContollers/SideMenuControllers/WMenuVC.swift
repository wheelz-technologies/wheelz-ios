//
//  WMenuVC.swift
//  Fender
//
//  Created by Neha Chhabra on 04/08/16.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class WMenuVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var menuArray = NSMutableArray()

    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userProfileImageView: UIImageView!
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
          self.customInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.customInit()
        userNameLabel!.text = UserDefaults.standard.value(forKey: "wheelzUserName") as? String
        self.userProfileImageView.layer.borderColor = UIColor.gray.cgColor
        self.userProfileImageView.layer.borderWidth = 2.0
        
        if ((UserDefaults.standard.value(forKey: "wheelzUserPic") as? String)! != "") {
            (self.userProfileImageView as! CustomImageView).customInit((UserDefaults.standard.value(forKey: "wheelzUserPic") as! String))
        }
    }

    //MARK:- Memory Management Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    //MARK:- Helper Methods
    func customInit() -> Void {
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
        menuArray = ["HOME","ACCOUNT","LESSONS","PAYMENTS","VEHICLES",/*"ALERTS", "HELP",*/ "SIGN OUT"]
        } else {
        menuArray = ["HOME","ACCOUNT","LESSONS","PAYMENTS",/*"ALERTS", "HELP",*/ "SIGN OUT"]
        }
        getRoundImage(userProfileImageView)
    }
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WMenuTVCellID", for: indexPath) as! WMenuTVCell
        if (indexPath.row % 2) == 0 {
            cell.backgroundColor = kAppDarkGrayColor
        }
        cell.menuLabel.text = menuArray.object(at: indexPath.row) as? String
             return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let drawerController = kAppDelegate.navController!.topViewController as! KYDrawerController
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            
            switch indexPath.row {
            case 0:
                let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
                drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 1:
                let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "WAccountVCID") as! WAccountVC
                drawerController.mainViewController = UINavigationController(rootViewController : accountVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 2:
                let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "WHistoryVCID") as! WHistoryVC
                drawerController.mainViewController = UINavigationController(rootViewController : historyVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 3:
                let paymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WDriverPaymentsVCID") as! WDriverPaymentsVC
                drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 4:
                let vehiclesVC = self.storyboard?.instantiateViewController(withIdentifier: "WVehiclesVCID") as! WVehiclesVC
                drawerController.mainViewController = UINavigationController(rootViewController : vehiclesVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            /*case 5:
                let alertsVC = self.storyboard?.instantiateViewController(withIdentifier: "WAlertsVCID") as! WAlertsVC
                drawerController.mainViewController = UINavigationController(rootViewController : alertsVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
              case 5:
                let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                drawerController.mainViewController = UINavigationController(rootViewController : helpVC)
                drawerController.setDrawerState(.closed, animated: true)*/
                break
            default:
                AlertController.alert("", message: "Are you sure you want to sign out?", controller: self,buttons: ["No", "Yes"], tapBlock: { (alertAction, position) -> Void in
                    if position == 0 {
                        // do nothing
                    } else if position == 1 {
                        UserDefaults.standard.setValue("", forKey: "wheelzUserID")
                        UserDefaults.standard.setValue("", forKey: "wheelzUserName")
                        UserDefaults.standard.setValue("", forKey: "wheelzUserPassword")
                        UserDefaults.standard.set(false, forKey: "wheelzIsDriver")
                        UserDefaults.standard.set(false, forKey: "wheelzIsInstructor")
                        UserDefaults.standard.setValue("", forKey: "wheelzUserPic")
                        UserDefaults.standard.synchronize()
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                })
                
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "WMapViewControllerID") as! WMapViewController
                drawerController.mainViewController = UINavigationController(rootViewController : mapVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 1:
                let accountVC = self.storyboard?.instantiateViewController(withIdentifier: "WAccountVCID") as! WAccountVC
                drawerController.mainViewController = UINavigationController(rootViewController : accountVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 2:
                let historyVC = self.storyboard?.instantiateViewController(withIdentifier: "WHistoryVCID") as! WHistoryVC
                drawerController.mainViewController = UINavigationController(rootViewController : historyVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 3:
                let paymentsVC = self.storyboard?.instantiateViewController(withIdentifier: "WPaymentsVCID") as! WPaymentsVC
                drawerController.mainViewController = UINavigationController(rootViewController : paymentsVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            /* case 4:
                let alertsVC = self.storyboard?.instantiateViewController(withIdentifier: "WAlertsVCID") as! WAlertsVC
                drawerController.mainViewController = UINavigationController(rootViewController : alertsVC)
                drawerController.setDrawerState(.closed, animated: true)
                break
            case 4:
                let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "WTipManagerVCID") as! WTipManagerVC
                drawerController.mainViewController = UINavigationController(rootViewController : helpVC)
                drawerController.setDrawerState(.closed, animated: true)*/
                break
            default:
                AlertController.alert("", message: "Are you sure you want to sign out?", controller: self,buttons: ["No", "Yes"], tapBlock: { (alertAction, position) -> Void in
                    if position == 0 {
                        // do nothing
                    } else if position == 1 {
                        SBDMain.disconnect(completionHandler: {
                            UserDefaults.standard.setValue("", forKey: "wheelzUserID")
                            UserDefaults.standard.setValue("", forKey: "wheelzUserName")
                            UserDefaults.standard.setValue("", forKey: "wheelzUserPassword")
                            UserDefaults.standard.set(false, forKey: "wheelzIsDriver")
                            UserDefaults.standard.set(false, forKey: "wheelzIsInstructor")
                            UserDefaults.standard.setValue("", forKey: "wheelzUserPic")
                            UserDefaults.standard.synchronize()
                            //SignalRManager.sharedInstance.manageConnection()
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                    }
                })
                
                break
            }
        }
    }
}
