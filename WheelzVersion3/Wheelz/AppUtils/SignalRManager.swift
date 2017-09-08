//
//  SocketIOManager.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2016-11-29.
//  Copyright © 2016 Fender Technologies Inc. All rights reserved.
//

import SwiftR

class SignalRManager: NSObject {
    static let sharedInstance = SignalRManager()
    //var socket = SocketIOClient(socketURL: URL(string: "\(apiUrl):443")!, config: [.log(false), .forcePolling(true)])
    
    var connection = SignalR("\(apiUrl)", connectionType: .persistent)
    
    override init() {
        super.init()

        connection.received = { data in
            if(data != nil)
            {
               print(data!) //determine action based on 'category' value
            }
        }
        
        connection.error = { error in
            print("Error: \(error)")
                
            if let source = error?["source"] as? String, source == "TimeoutException" {
                print("Connection timed out. Restarting...")
                self.connection.start()
            }
        }
    }
    
    func manageConnection() {
        let userId = UserDefaults.standard.value(forKey: "wheelzUserID") as? String ?? ""
        
        if(!userId.isEmpty) {
            connection.queryString = ["userId": userId]
            
            if connection.state == .connected {
                connection.stop()
            } else if connection.state == .disconnected {
                connection.start()
            }
        }
    }
    
    func establishConnection() {
        connection.start()
    }
    
    func closeConnection() {
        connection.stop()
    }
}
