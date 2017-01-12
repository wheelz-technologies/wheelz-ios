//
//  WHistoryController.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
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


class WHistoryVC: UIViewController,UITableViewDataSource,UITableViewDelegate,lessonDetailDelegate {
    var historyArray = NSMutableArray()
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WHistoryVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    var lessonDetailView = WLessonDetailView()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customInit()
        self.callApiGetLessonHistory()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.navigationController?.isNavigationBarHidden = true
        self.historyTableView.estimatedRowHeight = 60
        self.historyTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Lessons"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        
        self.historyTableView.addSubview(self.refreshControl)
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
    
    func getDateFromDateString(_ date : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =   "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date!)
    }
    
    func openLessonDetail(_ lessonId: String)
    {
        lessonDetailView = Bundle.main.loadNibNamed("WLessonDetailView", owner: nil, options: nil)?[0] as! WLessonDetailView
        lessonDetailView.lessonID = lessonId
        lessonDetailView.customInit()
        lessonDetailView.frame = (kAppDelegate.window?.bounds)!
        lessonDetailView.delegate = self
        
        kAppDelegate.window?.rootViewController!.view.addSubview(lessonDetailView)
    }
    
    func imageTapped(img: AnyObject)
    {
        //TODO: view user profile on image tap
    }
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WHistoryTVCellID", for: indexPath) as! WHistoryTVCell
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? RGBA(252, g: 252, b: 252, a: 1) : RGBA(255, g: 255, b: 255, a: 1)
        let historyInfo = historyArray.object(at: indexPath.row) as! WLessonInfo
        cell.lessonId = historyInfo.lessonID
        
        if historyInfo.lessonStatus == "Completed" {
            cell.statusLabel.textColor = RGBA(0, g: 191, b: 255, a: 1)
            cell.statusLabel.text = historyInfo.lessonStatus
        } else if historyInfo.lessonStatus == "Started" {
            cell.statusLabel.textColor = kAppOrangeColor
            cell.statusLabel.text = historyInfo.lessonStatus
        }
        else if historyInfo.lessonStatus == "Missed" {
                cell.statusLabel.textColor = UIColor.red
                cell.statusLabel.text = historyInfo.lessonStatus
        } else {
            cell.statusLabel.textColor = UIColor.darkGray
            cell.statusLabel.text = historyInfo.lessonStatus
        }
        
        cell.amountLabel.text = (historyInfo.lessonAmount < 0 ? "$0" : String(format: "$%.1f", historyInfo.lessonAmount))
        cell.statusLabel.text = String(format:"%@", historyInfo.lessonStatus)
        cell.userNameLabel.text = (String(format: "%.@",historyInfo.lessonHolderName).isEmpty ? "No Driver Yet" : String(format: "%.@",historyInfo.lessonHolderName))
        cell.historyDateLabel.text = getDateFromTimeStamp(historyInfo.lessonTimestamp)
        getRoundImage(cell.userImageView)
        
        cell.userImageView.setImageWithUrl(URL(string: historyInfo.lessonHolderPic)!, placeHolderImage: UIImage(named: "userPic"))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(imageTapped(img:)))
        cell.userImageView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyInfo = historyArray.object(at: indexPath.row) as! WLessonInfo
        
        openLessonDetail(historyInfo.lessonID)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.callApiGetLessonHistory()
        refreshControl.endRefreshing()
    }
    
    // LessonDetailDelegate
    //MARK:- Lesson Detail Delegate Methods
    func removeViewWithLessonobj(_ lessonObj: WLessonInfo, isEdit : Bool,msg:String)  {
        lessonDetailView.removeFromSuperview()
        lessonDetailView.updateTimer?.invalidate()
        lessonDetailView.updateTimer = nil
        lessonDetailView.lessonObj = WLessonInfo()
        lessonDetailView.lessonID = nil
        NotificationCenter.default.removeObserver(lessonDetailView)
        
        if isEdit {
            let editLessonVC = self.storyboard?.instantiateViewController(withIdentifier: "WEditLessonVCID") as! WEditLessonVC
            editLessonVC.lessonObj = lessonObj
            self.present(UINavigationController(rootViewController : editLessonVC) , animated: true, completion: {
                //
                }
            )
        } else if msg != "" {
            delay(1.0, closure: {
                AlertController.alert("", message: msg)
            })
        } else {
            self.callApiGetLessonHistory()
        }
    }
    
    //MARK:- Web API Section
    fileprivate func callApiGetLessonHistory() {
        
        let paramDict = NSMutableDictionary()
        var apiNameGetHistoryLesson: String
        
        if (UserDefaults.standard.value(forKey: "wheelzIsDriver") as? Bool) == true {
            paramDict[WStudentID] = ""
            paramDict[WDriverID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
             apiNameGetHistoryLesson = kAPINameGetHistoryInfo("",driverId:(UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!)
        } else {
            paramDict[WStudentID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
            paramDict[WDriverID] = ""
           apiNameGetHistoryLesson = kAPINameGetHistoryInfo((UserDefaults.standard.value(forKey: "wheelzUserID") as? String)!,driverId:"")
        }
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetHistoryLesson, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                   let tempArray = responseObject as? NSMutableArray
                    if (tempArray == nil || (tempArray?.count) < 1)  {
                        self.messageLabel.text = "Looks like you haven't had any lessons yet."
                        self.historyTableView.reloadData()
                        self.historyTableView.separatorColor = UIColor.white;
                    }
                    else {
                        self.historyArray = WLessonInfo.getLessonHistoryInfo(responseObject! as! NSMutableArray)
                        self.historyTableView.reloadData()
                    }
                }
            }
        }
    }

}
