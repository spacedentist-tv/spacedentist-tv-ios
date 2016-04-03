//
//  SDDisconnectedController.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 04/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation
import UIKit
import UIImageViewAlignedSwift

class SDDisconnectedController : UIViewController {
    
    @IBOutlet var text: UILabel?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var background: UIImageViewAligned?
    
    override func viewDidLoad() {
        self.activityIndicator?.hidden = true
        
        if let bg = self.background {
            bg.alignment = UIImageViewAlignmentMask.TopLeft
        }
    }
    
    func setChromecastAvailable(available: Bool) {
        if let text = self.text {
            text.text = (available) ?
                            "Please choose a Chromecast to start Spacedentist.tv":
                            "You need a Chromecast on your network to start Spacedentist.tv";
        }
    }
    
    func setConnecting(connecting: Bool) {
        if let activityIndicator = self.activityIndicator {
            activityIndicator.hidden = !connecting
            if connecting {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        if let text = self.text {
            text.hidden = connecting
        }
    }
}