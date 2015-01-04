//
//  ConnectSheet.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 03/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation

protocol SDConnectSheetDelegate {
    func deviceSelected(selectedDevice: GCKDevice)
}

class SDConnectSheet : NSObject, UIActionSheetDelegate {
    var deviceMap = [Int: GCKDevice]()
    var delegate: SDConnectSheetDelegate
    var sheet: UIActionSheet? = nil
    
    init(deviceScanner: GCKDeviceScanner, delegate: SDConnectSheetDelegate) {
        self.delegate = delegate
        
        super.init()
        
        self.sheet = UIActionSheet(title: "Connect to device", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        
        for device in deviceScanner.devices as [GCKDevice] {
            let index = self.sheet!.addButtonWithTitle(device.friendlyName)
            deviceMap[index] = device
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        NSLog("clickedButtonAtIndex(\(buttonIndex))")
        if buttonIndex != self.sheet?.cancelButtonIndex {
            self.delegate.deviceSelected(self.deviceMap[buttonIndex]!)
        }
    }
}
