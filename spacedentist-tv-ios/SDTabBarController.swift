//
//  SDTabBarController.swift
//  spacedentist-tv-ios
//
//  Created by Michael Coffey on 04/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import UIKit

class SDTabBarConroller : UITabBarController,
    GCKDeviceScannerListener,
    GCKDeviceManagerDelegate,
    SDConnectedControllerDelegate {
    
    let applicationId: String = "CBEF7615"
    
    var connectedControler: SDConnectedController? = nil
    var disconnectedController: SDDisconnectedController? = nil
    
    lazy private var deviceScanner: GCKDeviceScanner = {
        let deviceScanner = GCKDeviceScanner(
            filterCriteria: GCKFilterCriteria(
                forAvailableApplicationWithID: self.applicationId
            )
        )
        deviceScanner.addListener(self)
        return deviceScanner
    }()
    
    var deviceManager: GCKDeviceManager? = nil
    var castChannel: GCKCastChannel? = nil
    
    @IBOutlet var buttonCast: UIBarButtonItem?
    
    var buttonMap = [UIButton: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let font = UIFont(name: "BebasNeue", size: 21) {
            var titleTextAttributes = [String: AnyObject]()
            titleTextAttributes[NSFontAttributeName] = font
            titleTextAttributes[NSForegroundColorAttributeName] = UIColor(white: 0.933333, alpha: 1)
            self.navigationController!.navigationBar.titleTextAttributes = titleTextAttributes
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
        checkEnableCastButton(false)
        
        self.deviceScanner.startScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkEnableCastButton(animated: Bool = true) {
        let available = self.deviceScanner.hasDiscoveredDevices
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
        if self.deviceManager?.applicationConnectionState == GCKConnectionState.Connected {
            showDisconect()
        } else {
            showConnect()
        }
    }
    
    func showConnect() {
        let alertController = UIAlertController(
            title: "Connect to device",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        
        for device in self.deviceScanner.devices {
            alertController.addAction(
                UIAlertAction(
                    title: device.friendlyName,
                    style: UIAlertActionStyle.Default,
                    handler: { action in
                        NSLog("device selected \(device.friendlyName)")
                        
                        self.deviceManager = GCKDeviceManager(
                            device: device as! GCKDevice,
                            clientPackageName: NSBundle.mainBundle().bundleIdentifier
                        )
                        
                        self.deviceManager!.delegate = self
                        self.deviceManager!.connect()
                        
                        // animate the cast icon while connecting
                        self.buttonCast?.image = UIImage.animatedImageNamed("cast_on", duration:1)
                        self.disconnectedController?.setConnecting(true)
                    }
                )
            )
        }
        
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: { action in
                    // do nothing when they click cancel
                }
            )
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showDisconect() {
        let alertController = UIAlertController(
            title: "Disconnect from \(self.deviceManager!.device.friendlyName)",
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Disconnect",
                style: UIAlertActionStyle.Destructive,
                handler: { action in
                    NSLog("disconnect pressed")
                    
                    self.deviceManager?.stopApplication()
                    self.deviceManager?.disconnect()
                    self.castOff()
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: { action in
                    // do nothing when they click cancel
                }
            )
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        // launch the application to start casting
        self.deviceManager?.launchApplication(self.applicationId)
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        // the app has launched so turn the cast icon on
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
        
        if let image = UIImage(named: "cast_on") {
            self.buttonCast?.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        self.selectedIndex = 1
    }
    
    func castOff() {
        self.disconnectedController?.setConnecting(false)
        
        if let image = UIImage(named: "cast_off") {
            self.buttonCast?.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        self.selectedIndex = 0
    }
    
    // SDConnectedControllerDelegate
    func buttonPressed(key: String) {
        if let cc = self.castChannel {
            let dictionary: NSMutableDictionary = NSMutableDictionary()
            dictionary.setValue("rc", forKey: "sdtv_msg")
            dictionary.setValue(key, forKey: "key")
            
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(
                    dictionary,
                    options: NSJSONWritingOptions.PrettyPrinted
                )
                
                if let textMessage = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                    cc.sendTextMessage(textMessage);
                }
            } catch {
                NSLog("there was an error creating the JSON to send to the cast channel")
            }
        }
    }
}
