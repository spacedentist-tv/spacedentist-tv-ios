//
//  SDDisconnectSheet.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 03/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation

protocol SDDisconnectSheetDelegate {
    func disconnectPressed()
}

class SDDisconnectSheet : NSObject, UIActionSheetDelegate {
    
    var delegate: SDDisconnectSheetDelegate
    var sheet: UIActionSheet
    
    init(deviceName: String, delegate: SDDisconnectSheetDelegate) {
        self.delegate = delegate
        
        sheet = UIActionSheet(title: deviceName, delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Disconnect")
        
        super.init()
        
        self.sheet.delegate = self
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == self.sheet.destructiveButtonIndex {
            delegate.disconnectPressed()
        }
    }
}
