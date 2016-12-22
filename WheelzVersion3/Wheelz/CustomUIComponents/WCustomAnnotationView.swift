//
//  WCustomAnnotationView.swift
//  Wheelz
//
//  Created by Neha Chhabra on 08/09/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import MapKit

@objc protocol lessonSelectDelegate{
    @objc optional func selectLessonId(_ lessonId : String, view : UIView)
}

class WCustomAnnotationView: UIView, UITableViewDataSource, UITableViewDelegate {

     var selectDelegate: lessonSelectDelegate?
    var locationArray = NSMutableArray()
    
    @IBOutlet weak var annotationTableView: UITableView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
         annotationTableView.register(UINib(nibName: "WCustomAnnotationTVCell", bundle: nil), forCellReuseIdentifier: "WCustomAnnotationTVCellID")
        annotationTableView.delegate = self
        annotationTableView.dataSource = self
        annotationTableView.reloadData()
        annotationTableView.estimatedRowHeight = 80
        annotationTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK:- UITableView Delegate and Datasource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WCustomAnnotationTVCellID")! as! WCustomAnnotationTVCell
        let lessonObj = locationArray.object(at: indexPath.row)  as! WLessonInfo
        cell.dateLabel!.text = getDateFromTimeStamp(lessonObj.lessonTimestamp)
        cell.timeLabel!.text = getTimeFromTimeStamp(lessonObj.lessonTimestamp)
        print(lessonObj.lessonID)
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lessonObj = locationArray.object(at: indexPath.row)  as! WLessonInfo
        print(lessonObj.lessonID)
        selectDelegate!.selectLessonId!(lessonObj.lessonID,view: self)
    }
    
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func getDateFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    func getTimeFromTimeStamp(_ timeStamp : Double) -> String {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: date)
    }

}
