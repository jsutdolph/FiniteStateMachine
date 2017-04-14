//
//  ViewController.swift
//  Turnstile
//
//  Created by James Sutton on 14/04/2017.
//  Copyright © 2017 Dolphin Computing Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TurnstileProto {

	var fsm : TurnstileFSM?

	var coinEntered = false
	var pushed = false

	@IBOutlet var stateLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		stateLabel.text = "Locked"
		fsm = TurnstileFSM(turnstile: self)
	}

	@IBAction func coinPressed(_ sender: Any) {
		coinEntered = true;
		if let fsm = fsm
		{
			if !fsm.cycleUntilStable(client: self, maxCycles : 2)
			{
				print("State Machine fault!") // we expect to arrive at a stable result in 2 cycles
			}
		}
	}
	
	@IBAction func pushPressed(_ sender: Any) {
		pushed = true
		if let fsm = fsm
		{
			if !fsm.cycleUntilStable(client: self, maxCycles : 2)
			{
				print("State Machine fault!") // we expect to arrive at a stable result in 2 cycles
			}
		}
	}


	//protocol TurnstileProto
	func coin() -> Bool {
		return coinEntered;
	}
	
	func push() -> Bool {
		return pushed;
	}
	
	func unlock() {
		stateLabel.text = "Unlocked"
		coinEntered = false
	}
	
	func lock() {
		stateLabel.text = "Locked"
		pushed = false
	}
}

