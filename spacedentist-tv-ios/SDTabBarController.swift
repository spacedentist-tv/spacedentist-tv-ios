//
//  SDTabBarController.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 04/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import Foundation

class SDTabBarConroller : UITabBarController,
    GCKDeviceScannerListener,
    GCKDeviceManagerDelegate,
    SDConnectSheetDelegate,
    SDDisconnectSheetDelegate,
    SDConnectedControllerDelegate {
    
    let applicationId: String = "CBEF7615"
    
    var connectedControler: SDConnectedController? = nil
    var disconnectedController: SDDisconnectedController? = nil
    
    var deviceScanner: GCKDeviceScanner? = nil
    var filterCriteria: GCKFilterCriteria? = nil
    var deviceManager: GCKDeviceManager? = nil
    var castChannel: GCKCastChannel? = nil
    
    var connectSheet: SDConnectSheet? = nil
    var disconnectSheet: SDDisconnectSheet? = nil
    
    @IBOutlet var buttonCast: UIBarButtonItem?
    
    var buttonMap = [UIButton: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let font = UIFont(name: "BebasNeue", size: 21) {
            let titleTextAttributes = NSMutableDictionary()
            titleTextAttributes.setObject(font, forKey: NSFontAttributeName)
            titleTextAttributes.setObject(UIColor(white: 0.933333, alpha: 1), forKey: NSForegroundColorAttributeName)
            self.navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
        }
        
        if let connectedController = self.viewControllers?[1] as? SDConnectedController {
            self.connectedControler = connectedController
            connectedController.delegate = self
        }
        if let disconnectedController = self.viewControllers?[0] as? SDDisconnectedController {
            self.disconnectedController = disconnectedController
        }
        
        // hide the cast icon
        castOff()
        checkEnableCastButton(animated: false)
        
        self.deviceScanner = GCKDeviceScanner()
        self.filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: self.applicationId)
        self.deviceScanner?.filterCriteria = filterCriteria
        self.deviceScanner?.addListener(self)
        self.deviceScanner?.startScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkEnableCastButton(animated: Bool = true) {
        var available: Bool = false
        
        if let ds = self.deviceScanner {
            available = deviceScanner!.hasDiscoveredDevices
        }
        
        self.navigationItem.setRightBarButtonItem(available ? self.buttonCast : nil, animated: animated)
        
        self.disconnectedController?.setChromecastAvailable(available)
    }
    
    func deviceDidComeOnline(device: GCKDevice!) {
        checkEnableCastButton()
    }
    
    func deviceDidGoOffline(device: GCKDevice!) {
        checkEnableCastButton()
    }
    
    @IBAction func castButtonPressed(button: AnyObject) {
        if let dm = self.deviceManager {
            if  dm.isConnectedToApp {
                NSLog("there's a device manager and it's connected to the app!")
                self.disconnectSheet = SDDisconnectSheet(deviceName: dm.device.friendlyName, delegate: self)
                self.disconnectSheet?.sheet.showFromBarButtonItem(self.buttonCast, animated: true)
            } else {
                // there was a device manager, but it wasn't connected
                self.connectSheet = SDConnectSheet(deviceScanner: self.deviceScanner!, delegate: self)
                self.connectSheet?.sheet?.showFromBarButtonItem(self.buttonCast, animated: true)
            }
        } else {
            // there's no device manager
            self.connectSheet = SDConnectSheet(deviceScanner: self.deviceScanner!, delegate: self)
            self.connectSheet?.sheet?.showFromBarButtonItem(self.buttonCast, animated: true)
        }
    }
    
    func deviceSelected(device: GCKDevice) {
        NSLog("device selected \(device.friendlyName)")
        
        self.deviceManager = GCKDeviceManager(device: device, clientPackageName: NSBundle.mainBundle().bundleIdentifier)
        
        self.deviceManager?.delegate = self
        self.deviceManager?.connect()
        
        // animate the cast icon while connecting
        self.buttonCast?.image = UIImage.animatedImageNamed("CastOn", duration:1)
        self.disconnectedController?.setConnecting(true)
    }
    
    func disconnectPressed() {
        NSLog("disconnect pressed")
        
        self.deviceManager?.stopApplication()
        self.deviceManager?.disconnect()
        castOff()
    }
    
    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        // launch the application to start casting
        self.deviceManager?.launchApplication(self.applicationId)
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        // the app has launched to turn the cast icon on
        castOn()
        
        self.castChannel = SDCastChannel()
        self.deviceManager?.addChannel(self.castChannel)
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!, didDisconnectFromApplicationWithError error: NSError!) {
        castOff()
        if let gckError = GCKErrorCode(rawValue: error.code) {
            NSLog("Disconnected: \(GCKError.enumDescriptionForCode(gckError))")
        }
    }
    
    func castOn() {
        self.disconnectedController?.setConnecting(false)
        
        if let image = UIImage(named: "CastOn") {
            self.buttonCast?.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        self.selectedIndex = 1
    }
    
    func castOff() {
        self.disconnectedController?.setConnecting(false)
        
        if let image = UIImage(named: "CastOff") {
            self.buttonCast?.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        self.selectedIndex = 0
    }
    
    // SDConnectedControllerDelegate
    func buttonPressed(key: String) {
        if let cc = self.castChannel? {
            let dictionary: NSMutableDictionary = NSMutableDictionary()
            dictionary.setValue("rc", forKey: "sdtv_msg")
            dictionary.setValue(key, forKey: "key")
            
            var error: NSErrorPointer = nil
            
            if let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: error) {
                cc.sendTextMessage(NSString(data: data, encoding: NSUTF8StringEncoding));
            }
        }
    }
}
