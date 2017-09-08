//
//  WPaymentsController.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-08-11.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import UIKit
import Stripe
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


class WPaymentsVC: UIViewController,UITableViewDataSource,UITableViewDelegate, STPAddCardViewControllerDelegate,BWSwipeCellDelegate,BWSwipeRevealCellDelegate {

    var paymentsArray = NSMutableArray()
    @IBOutlet weak var paymentTableView: UITableView!
    @IBOutlet weak var staticNoRecordLabel: UILabel!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WPaymentsVC.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callAPIForGetCards()
    }
    
    // MARK: - Private Methods
    fileprivate func customInit() {
        self.paymentTableView.estimatedRowHeight = 60
        self.paymentTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationItem.title = "Payments"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        self.navigationItem.rightBarButtonItem = WAppUtils.rightBarButton("add", controller: self)
        
        self.paymentTableView.addSubview(self.refreshControl)
    }
    
    func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    func rightBarButtonAction(_ button : UIButton) {
        self.addCard()
    }
    
    func addCard() {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // STPAddCardViewController must be shown inside a UINavigationController.
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: STPAddCardViewControllerDelegate
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        self.submitTokenToBackend(token)
    }
    
    func submitTokenToBackend(_ token: STPToken)
    {
        let paramDict = NSMutableDictionary()
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WStripeToken] = token.tokenId
        
        let apiNameAddCard = kAPINameAddCard(paramDict.value(forKey: WUserID) as! String, token: paramDict.value(forKey: WStripeToken) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .put, apiName: apiNameAddCard, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                self.dismiss(animated: true, completion: nil)
                self.callAPIForGetCards()
            }
            
        }
    }
    
    //MARK:- Tableview Datasource And Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WPaymentTVCellID", for: indexPath) as! WPaymentTVCell
        //cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? RGBA(255, g: 245, b: 245, a: 1) : RGBA(255, g: 255, b: 255, a: 1)
        let cardInfo =  paymentsArray.object(at: indexPath.row) as? WCardInfo
        
        switch cardInfo!.brand {
        case "Visa":
            cell.cardImageView.image = UIImage(named:"visaIcon")!
            cell.cardTypeLabel.text = "Visa"
            cell.cardInfoLabel.text = "ending in " + (cardInfo?.last4)!
            break
        case "MasterCard":
            cell.cardImageView.image = UIImage(named:"masterCardIcon")!
            cell.cardTypeLabel.text = "MasterCard"
            cell.cardInfoLabel.text = "ending in " + (cardInfo?.last4)!
            break
        default:
            break
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
        
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.callAPIForGetCards()
        refreshControl.endRefreshing()
    }
    
    //MARK:- Web API Section
    func callAPIForGetCards() {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        
        let apiNameGetCards = kAPINameGetAllCards(paramDict.value(forKey: WUserID) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .get, apiName: apiNameGetCards, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
            if error != nil {
                AlertController.alert("",message: (error?.localizedDescription)!)
            } else {
                if (responseObject != nil) {
                    let tempArray = responseObject as? NSMutableArray
                    if ((tempArray?.count)  < 1 || tempArray == nil)  {
                        self.staticNoRecordLabel.text = "You haven't added any cards yet. Add one now!"
                        
                    } else {
                        self.staticNoRecordLabel.text = ""
                        
                    }
                    self.paymentsArray = WCardInfo.getCardInfo(responseObject! as! NSMutableArray)
                    
                    self.paymentTableView.reloadData()
                    
                }
            }
        }
    }
    
    // MARK: - Reveal Cell Delegate
    
    func callAPIForDeleteCard(_ cardId: String) {
        
        let paramDict = NSMutableDictionary()
        
        paramDict[WUserID] = UserDefaults.standard.value(forKey: "wheelzUserID") as? String
        paramDict[WCardId] = cardId
        
        let apiNameDeleteCard = kAPINameDeleteCard(paramDict.value(forKey: WCardId) as! String, cardId: paramDict.value(forKey: WCardId) as! String)
        
        ServiceHelper.sharedInstance.callAPIWithParameters(paramDict, method: .delete, apiName: apiNameDeleteCard, hudType: .default) { (responseObject :AnyObject?, error:NSError?,data:Data?) in
            
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
                        self.callAPIForGetCards()
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
    
    func swipeCellWillRelease(_ cell: BWSwipeCell) {
        if cell.state != .normal && cell.type != .slidingDoor {
            let indexPath: IndexPath = paymentTableView.indexPath(for: cell)!
            let cardObj = paymentsArray.object(at: indexPath.row) as! WCardInfo
            callAPIForDeleteCard(cardObj.id)
        }
    }
    
    func swipeCellActivatedAction(_ cell: BWSwipeCell, isActionLeft: Bool) {
        AlertController.alert("", message: "Delete this card?",controller: self, buttons: ["No","Yes"], tapBlock: { (alertAction, position) -> Void in
            if position == 1 {
                let indexPath: IndexPath = self.paymentTableView.indexPath(for: cell)!
                let cardObj = self.paymentsArray.object(at: indexPath.row) as! WCardInfo
                print(cardObj.id)
                self.callAPIForDeleteCard(cardObj.id)
            }
        })
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
}
