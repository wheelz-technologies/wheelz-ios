//
//  WVehiclesControllerVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class WVehiclesVC: UIViewController,UITableViewDataSource,UITableViewDelegate,BWSwipeCellDelegate,BWSwipeRevealCellDelegate,UITextFieldDelegate {
    var vehiclesArray = NSMutableArray()
    @IBOutlet weak var vehiclesTableView: UITableView!
    
    @IBOutlet weak var staticNoRecordLabel: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WVehiclesVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callAPIForGetVehicle()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.vehiclesTableView.estimatedRowHeight = 60
        self.vehiclesTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Vehicles"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("add", controller: self)
        
        self.vehiclesTableView.addSubview(self.refreshControl)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        let addVehicleVC = self.storyboard?.instantiateViewController(withIdentifier: "WAddVehicleVCID") as! WAddVehicleVC
        addVehicleVC.isUpdateVehicle = false
        for case let item as WVehiclesInfo in vehiclesArray {
            if item.isMain == true {
                addVehicleVC.isMainVehicleExists = true
                break
            } else {
                addVehicleVC.isMainVehicleExists = false
            }
        }
        
        self.navigationController?.pushViewController(addVehicleVC, animated: true)
    }
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehiclesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WVehicleTVCellID", for: indexPath) as! WVehicleTVCell
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? RGBA(255, g: 245, b: 245, a: 1) : RGBA(255, g: 255, b: 255, a: 1)
        let vehiclesInfo =  vehiclesArray.object(at: indexPath.row) as? WVehiclesInfo
        cell.modelYearLabel.text = vehiclesInfo!.year + " " + vehiclesInfo!.make + " " + vehiclesInfo!.model
        cell.vinLabel.text = String(vehiclesInfo!.vin.characters.suffix(4))
        if vehiclesInfo?.isMain == true {
            cell.modelYearLabel.font = UIFont(name:"Futura", size:16)!
            cell.vinLabel.font = UIFont(name:"Futura", size:16)!
        } else {
            cell.modelYearLabel.font = kAppFont(18)
            cell.vinLabel.font = kAppFont(18)
        }
        cell.bgViewRightImage = UIImage(named:"delete")!.withRenderingMode(.alwaysOriginal)
        cell.bgViewRightColor = UIColor.red
        cell.delegate = self
        
        cell.type = .slidingDoor
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addVehicleVC = self.storyboard?.instantiateViewController(withIdentifier: "WAddVehicleVCID") as! WAddVehicleVC
        addVehicleVC.isUpdateVehicle = true
        let vehicleInfo = vehiclesArray.object(at: indexPath.row) as? WVehiclesInfo
        addVehicleVC.vehicleObj = vehicleInfo
        
        for case let item as WVehiclesInfo in vehiclesArray {
            if item.isMain == true {
                addVehicleVC.isMainVehicleExists = vehiclesArray.count > 1 ?  false : true
                break
            } else {
                addVehicleVC.isMainVehicleExists = false
            }
        }
        
        if(vehiclesArray.count == 1) {
            addVehicleVC.isOnlyVehicle = true
        }
        self.navigationController?.pushViewController(addVehicleVC, animated: true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.callAPIForGetVehicle()
        refreshControl.endRefreshing()
    }
   
    // MARK: - Reveal Cell Delegate
    
    func swipeCellWillRelease(_ cell: BWSwipeCell) {
        if cell.state != .normal && cell.type != .slidingDoor {
            let indexPath: IndexPath = vehiclesTableView.indexPath(for: cell)!
            let vehicleObj = vehiclesArray.object(at: indexPath.row) as! WVehiclesInfo
            callAPIForDeleteVehicle(vehicleObj.vehicleId)
        }
    }
    
    func swipeCellActivatedAction(_ cell: BWSwipeCell, isActionLeft: Bool) {
        if(vehiclesArray.count == 1) {
            AlertController.alert("Delete Vehicle", message: "Sorry, you must have at least one vehicle.")
        } else {
         AlertController.alert("", message: "Delete this vehicle?",controller: self, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
            if position == 1 {
                let indexPath: IndexPath = self.vehiclesTableView.indexPath(for: cell)!
                let vehicleObj = self.vehiclesArray.object(at: indexPath.row) as! WVehiclesInfo
                self.callAPIForDeleteVehicle(vehicleObj.vehicleId)
            }
         })
        }
    }
    
    func swipeCellDidChangeState(_ cell: BWSwipeCell) {
        if cell.state != .normal {
        } else {
        }
    }
    
    func swipeCellDidCompleteRelease(_ cell: BWSwipeCell) {
    }
    
    func swipeCellDidSwipe(_ cell: BWSwipeCell) {
    }
    
    func swipeCellDidStartSwiping(_ cell: BWSwipeCell) {
        let panGesture = UIPanGestureRecognizer()
        panGesture.isLeft(cell.contentView)
    }
    
     //MARK:- Web API Section
     func callAPIForGetVehicle() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetVehicle = kAPINameGetDriverVehicles(paramDict.value(forKey: WDriverID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        self.staticNoRecordLabel.text = "You don't have any vehicles yet. Add one now!"
                                          } else {
                         self.staticNoRecordLabel.text = ""
                        
                    }
                    self.vehiclesArray = WVehiclesInfo.getVehiclesInfo(responseObject! as! NSMutableArray)

                    self.vehiclesTableView.reloadData()

                }
            }
            
        }
    }
    
     func callAPIForDeleteVehicle(_ vehicleID: String) {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WVehicleID] = vehicleID
        let apiNameDeleteVehicle = kAPINameDeleteVehicle(paramDict.value(forKey: WVehicleID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .delete, apiName: apiNameDeleteVehicle, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let message = responseObject?.object(forKey: "message") as? String ?? ""
                    let msg = responseObject?.object(forKey: "Message") as? String ?? ""
                    if msg != "" {
                        AlertController.alert("", message: msg,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                            }
                        })
                        return
                    }
                    if message != "" {
                        self.callAPIForGetVehicle()
                    } else {
                        AlertController.alert("", message: message,controller: self, buttons: ["OK"], tapBlock: { (alertAction, position) -> Void in
                            if position == 0 {
                            }
                        })
                    }
                }
            }
            
        }
    }
    
   
}
