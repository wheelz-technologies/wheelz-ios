//
//  SocketIOManager.swift
//  Wheelz
//
//  Created by Arseniy Nikulchenko on 2016-11-29.
//  Copyright © 2016 Wheelz Technologies Inc. All rights reserved.
//

import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket = SocketIOClient(socketURL: URL(string: "\(apiUrl):443")!, config: [.log(false), .forcePolling(true)])
    
    override init() {
        super.init()
        
        let userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? ""
        
        if(!userId.isEmpty) {
            socket.on(userId) { dataArray, ack in
                print("\\\\\\\\\\\\\\\\\\\\\\\\\\\(dataArray)")
                AlertController.alert("Works")
            }
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
