//
//  SDChannel.swift
//  spacedentist tv ios
//
//  Created by Michael Coffey on 01/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation

class SDCastChannel : GCKCastChannel {
    let namespace: String = "urn:x-cast:tv.spacedentist.cast"
    
    override init() {
        super.init(namespace: self.namespace)
    }
    
    override func didReceiveTextMessage(message: String!) {
        NSLog(message)
    }
}