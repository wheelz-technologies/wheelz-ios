//
//  WCustomAnnotation.swift
//  Wheelz
//
//  Created by Neha Chhabra on 08/09/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit
import MapKit

class WCustomAnnotation: NSObject,MKAnnotation {
    
    var lessonArray = NSMutableArray()
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var lessonID: String?
    var driverID: String = ""
    var studentID: String = ""
    var isConfirmed = false
    var isInstructorRequired = false
    var type = 0
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
