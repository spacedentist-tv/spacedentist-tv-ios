//
//  SDDisconnectedController.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 04/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation


class SDDisconnectedController : UIViewController {
    
    @IBOutlet var text: UILabel?
    
    func setChromecastAvailable(available: Bool) {
        if let text = self.text {
            text.text = (available) ?
                            "Please choose a Chromecast to start Spacedentist.tv":
                            "You need a Chromecast on your network to start Spacedentist.tv";
        }
    }
    
}