//
//  ViewController.swift
//  Calculator
//
//  Created by Ryan Barrett on 1/28/16.
//  Copyright © 2016 Ryan Barrett. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()

    @IBAction func digitPressed(sender: UIButton) {
        if sender.currentTitle == "π" {
            let digit = M_PI
            //print("digit = \(digit)")
            display.text = String(format:"%f", digit)
        }
        else{
            let digit = sender.currentTitle!
            //print("digit = \(digit)")
            if userIsInTheMiddleOfTypingANumber {
                display.text = display.text! + digit
            } else{
                display.text = digit
                userIsInTheMiddleOfTypingANumber = true
            }
        }
        
    }

    @IBAction func clear() {
        brain.clearStack()
        display.text = "0"
        history.text = ""
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        var count = 0
        for i in display.text!.characters {
            if i == "." {
                count += 1
            }
        }
        if count < 2 {
            if let result = brain.pushOperand(displayValue!){
                displayValue = result
            } else{
                displayValue = 0
            }
        }
        else {
            display.text = "0"
        }
        
    }
    
    @IBAction func operate(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle! {
            if let result = brain.performOperation(operation) {
                history.text = ("\(display.text!) \(history.text!)")
                displayValue = result
            } else{
                displayValue = 0
            }
        }
        history.text = brain.getString()
        print (brain.getString())
       
    }

    
    @IBAction func getVariable(sender: AnyObject) {
        brain.pushOperand("M")
    }
    
    @IBAction func setVariable(sender: AnyObject) {
        brain.storeVar("M", value: displayValue!)
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue!)"
        }
    }
    
}

