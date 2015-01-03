//
//  ViewController.swift
//  spacedentist tv ios
//
//  Created by Michael Coffey on 01/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                        GCKDeviceScannerListener,
                        GCKDeviceManagerDelegate,
                        UIActionSheetDelegate {
    
    let applicationId: String = "E7EFD798"
    
    var deviceScanner: GCKDeviceScanner? = nil
    var filterCriteria: GCKFilterCriteria? = nil
    var deviceManager: GCKDeviceManager? = nil
    var castChannel: GCKCastChannel? = nil
    
    @IBOutlet var buttonCast: UIBarButtonItem?
    
    @IBOutlet var buttonOne: UIButton?
    @IBOutlet var buttonTwo: UIButton?
    @IBOutlet var buttonThree: UIButton?
    @IBOutlet var buttonFour: UIButton?
    @IBOutlet var buttonFive: UIButton?
    @IBOutlet var buttonSix: UIButton?
    @IBOutlet var buttonSeven: UIButton?
    @IBOutlet var buttonEight: UIButton?
    @IBOutlet var buttonNine: UIButton?
    @IBOutlet var buttonZero: UIButton?
    @IBOutlet var buttonText: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // hide the cast icon
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
        let item = (deviceScanner?.devices.count > 0) ? self.buttonCast : nil
        
        self.navigationItem.setRightBarButtonItem(item, animated: animated)
    }

    func deviceDidComeOnline(device: GCKDevice!) {
        checkEnableCastButton()
    }
    
    func deviceDidGoOffline(device: GCKDevice!) {
        checkEnableCastButton()
    }
    
    @IBAction func castButtonPressed(button: AnyObject) {
        if let dm = self.deviceManager {
            if  dm.isConnected {
                NSLog("there's a device manager and it's connected!")
                dm.stopApplication()
                dm.disconnect()
                if let bc = self.buttonCast? {
                    bc.image = UIImage(named: "CastOff")
                }
            } else {
                // there was a device manager, but it wasn't connected
                showCastSheet()
            }
        } else {
            // there's no device manager
            showCastSheet()
        }
    }

    func showCastSheet() {
        let sheet = UIActionSheet(title: "Cast", delegate: self,
            cancelButtonTitle: nil,
            destructiveButtonTitle: nil)
        
        for device in self.deviceScanner?.devices as [GCKDevice] {
            sheet.addButtonWithTitle(device.friendlyName)
        }
        
        sheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        connect(self.deviceScanner?.devices[buttonIndex] as GCKDevice)
    }
    
    func connect(device: GCKDevice) {
        self.deviceManager = GCKDeviceManager(device: device, clientPackageName: "")
        
        self.deviceManager?.delegate = self
        self.deviceManager?.connect()
        
        self.buttonCast?.image = UIImage.animatedImageNamed("CastOn", duration:1)
    }
    
    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        // launch the application to start casting
        self.deviceManager?.launchApplication(self.applicationId)
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        // the app has launched to turn the cast icon on
        self.buttonCast?.image = UIImage(named: "CastOn")
        
        self.castChannel = SDCastChannel()
        self.deviceManager?.addChannel(self.castChannel)
    }
    
    func getKey(button: UIButton) -> String {
        if button == self.buttonOne {
            return "1"
        } else if button == self.buttonTwo {
            return "2"
        } else if button == self.buttonThree {
            return "3"
        } else if button == self.buttonFour {
            return "4"
        } else if button == self.buttonFive {
            return "5"
        } else if button == self.buttonSix {
            return "6"
        } else if button == self.buttonSeven {
            return "7"
        } else if button == self.buttonEight {
            return "8"
        } else if button == self.buttonNine {
            return "9"
        } else if button == self.buttonZero {
            return "0"
        } else if button == self.buttonText {
            return "cycle"
        }
        
        return "";
    }
    
    @IBAction func buttonTapped(button: UIButton) {
        NSLog("button tapped!")
        
        if let cc = self.castChannel? {
            let dictionary: NSMutableDictionary = NSMutableDictionary()
            dictionary.setValue("rc", forKey: "sdtv_msg")
            let key = getKey(button)
            NSLog("key: %@", key)
            
            dictionary.setValue(key, forKey: "key")
            
            var error: NSErrorPointer = nil
            
            if let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: error) {
                cc.sendTextMessage(NSString(data: data, encoding: NSUTF8StringEncoding));
            }
        }
    }
}

