//
//  ViewController.swift
//  spacedentist tv ios
//
//  Created by Michael Coffey on 01/01/2015.
//  Copyright (c) 2015 Michael Coffey. All rights reserved.
//

import UIKit

protocol SDConnectedControllerDelegate {
    func buttonPressed(key: String)
}

class SDConnectedController: UIViewController {
    
    var delegate: SDConnectedControllerDelegate? = nil
    
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
    
    var buttonMap = [UIButton: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.buttonMap[self.buttonOne!] = "1"
        self.buttonMap[self.buttonTwo!] = "2"
        self.buttonMap[self.buttonThree!] = "3"
        self.buttonMap[self.buttonFour!] = "4"
        self.buttonMap[self.buttonFive!] = "5"
        self.buttonMap[self.buttonSix!] = "6"
        self.buttonMap[self.buttonSeven!] = "7"
        self.buttonMap[self.buttonEight!] = "8"
        self.buttonMap[self.buttonNine!] = "9"
        self.buttonMap[self.buttonZero!] = "0"
        self.buttonMap[self.buttonText!] = "cycle"
    }
    
    @IBAction func buttonTapped(button: UIButton) {
        if let safeDelegate = self.delegate {
            if let key = buttonMap[button] {
                NSLog("button tapped! \(key)")
                safeDelegate.buttonPressed(key);
            }
        }
    }
}

