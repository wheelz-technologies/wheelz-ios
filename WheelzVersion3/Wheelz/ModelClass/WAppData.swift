//
//  WAppData.swift
//  Wheelz
//
//  Created by Probir Chakraborty on 07/08/16.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import UIKit

class WAppData: NSObject {

    private static var __once: () = {
            Static.instance = WAppData()
        }()

    class var appInfoSharedInstance: WAppData {
        _ = WAppData.__once
        return Static.instance!
    }
    
    struct Static {
        static var onceToken: Int = 0
        static var instance: WAppData? = nil
    }
    
    var appUserInfo: WUserInfo!
}
