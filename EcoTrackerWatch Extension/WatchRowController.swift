//
//  WatchRowController.swift
//  EcoTracker
//
//  Created by Olga Blinova on 22/05/2017.
//  Copyright © 2017 Olga Blinova. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

class WatchRowController: NSObject {
    
    @IBOutlet var typeImage: WKInterfaceImage!
    @IBOutlet var greenButton: WKInterfaceButton!
    @IBOutlet var yellowButton: WKInterfaceButton!
    @IBOutlet var greyButton: WKInterfaceButton!
    
    @IBAction func acitonOnGrey() {
    }
    
    @IBAction func actionOnYellow() {
    }
    
    @IBAction func actionOnGreen() {
    }
    
    @IBAction func onRandomDataButton() {
        let session = WCSession.default()
        if session.isReachable {
            let dataValues = ["data": 10]
            session.sendMessage(dataValues,
                                replyHandler: { reply in
                                    //self.statusLabel.setHidden(false)
                                    //self.statusLabel.setText(reply["status"] as? String)
            }, errorHandler: { error in
                //
            })
        }
    }
}
