//
//  TurnstileFSM.swift
//  SnapScore
//
//  Created by James Sutton on 14/04/2017.
//
// see https://en.wikipedia.org/wiki/Finite-state_machine
//
// implementation of the coin-operated turnstile example
//

import Foundation

protocol TurnstileProto
{
	func coin() -> Bool
	func push() -> Bool
	func unlock()
	func lock()
}

class TurnstileFSM
{
	enum StateType {
		case Locked
		case Unlocked
	}
	
	private static let kStates : [State<StateType, TurnstileProto>] = [
		State(.Locked, transitions: [
			
			// Coin
			Transition( { (turnstile: TurnstileProto) in turnstile.coin()},
			            action: {(turnstile: TurnstileProto) in turnstile.unlock() }, toStateId: .Unlocked),

			// Push
			Transition( { (turnstile: TurnstileProto) in turnstile.push()},
			            action: { (turnstile: TurnstileProto) in return }, toStateId: .Locked)
			]),
		State(.Unlocked, transitions: [
			
			// Push
			Transition( { (turnstile: TurnstileProto) in turnstile.push()},
			            action: {(turnstile: TurnstileProto) in turnstile.lock() }, toStateId: .Locked),
		
			// Coin
			Transition( { (turnstile: TurnstileProto) in turnstile.coin()},
			            action: { (turnstile: TurnstileProto) in return }, toStateId: .Unlocked)
			])
	]
	
	let fsm : FSM<StateType, TurnstileProto>
	
	init(turnstile: TurnstileProto)
	{
		self.fsm = FSM(states: TurnstileFSM.kStates, initialStateId: .Locked)
	}
	
	func cycleUntilStable(client: TurnstileProto, maxCycles : Int) -> Bool
	{
		return fsm.cycleUntilStable(client: client, maxCycles: maxCycles)
	}

}
