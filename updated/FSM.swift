//
//  FSM.swift
//
//  You are free to copy and modify this code as you wish
//  No warranty is made as to the suitability of this for any purpose
//
//  A Generic Finite State Machine
//
//  Important Feature: All states can be completely specified in a static array
//

import Foundation

/**
	a state for a Finite State Machine
*/
class State<StateValue, TM, TC>
{
	let id : StateValue
	let transitions: [Transition<StateValue, TM, TC>]
	
	/**
	id a unique id for the state
	transitions a set of transitions which can take the FSM to a different state
	*/
	init(_ id: StateValue, transitions: [Transition<StateValue, TM, TC>])
	{
		self.id = id
		self.transitions = transitions
	}
	
	func findFirstTransition(client_model : TM, client_controller : TC) -> Int?
	{
		var index = 0
		for transition in transitions
		{
			if (transition.condition(client_model)) // we return the _first_ transition with true condition - ignore others
			{
				return index
			}
			index+=1
		}
		return nil
	}
}

/**
	a transition between states
*/
class Transition<StateValue, TM, TC>
{
	let condition : (TM) -> Bool
	let action : (TC) -> Void
	let toStateId : StateValue
	
	/**
	condition a condition for the transition (return true to make the transition)
	action a function to perform on making the transition
	toStateId the new state to arrive at after the transition
	*/
	init(_ condition: @escaping (TM) -> Bool, action: @escaping (TC) -> Void, toStateId: StateValue)
	{
		self.condition = condition
		self.action = action
		self.toStateId = toStateId
	}
}

/**
	A Finite State Machine
*/
class FSM<StateValue : Hashable, TM, TC>
{
	let logging = true
	let states : [StateValue : State<StateValue, TM, TC>]
	var currentState : State<StateValue, TM, TC>
	
	func log(_ items: Any...)
	{
		if logging
		{
			print(items)
		}
	}
	
	init(states : [State<StateValue, TM, TC>], initialStateId : StateValue)
	{
		var statesMap = [StateValue : State<StateValue, TM, TC>]()
		for state in states {
			statesMap[state.id] = state
		}
		self.states = statesMap
		self.currentState = statesMap[initialStateId]!
		assert(check())
		log(states.count, " states in FSM")
	}
	
	/** (for debug) check that all transitions specify valid end states in states list
	*/
	func check() -> Bool
	{
		for state in states.values
		{
			for transition in state.transitions
			{
				if let _ = states[transition.toStateId] {
					// nop
				}
				else {
					return false // transition specifies state not in states list
				}
			}
		}
		return true
	}
	
	/** make at most one state transition and return true if a transition was made
	*/
	func cycleOnce(client_model : TM, client_controller : TC) -> Bool
	{
		if let transitionIndex = currentState.findFirstTransition(client_model : client_model, client_controller : client_controller) { // find a transition with true condition
			let transition = currentState.transitions[transitionIndex]
			transition.action(client_controller) // perform its action
			let newState = states[transition.toStateId]! // move to new state - run-time error if state does not exist
			if newState.id != currentState.id
			{
				log("  transition ", transitionIndex, " change from ", String(describing:currentState.id), " to ", String(describing:newState.id))
				currentState = newState // change state
				return true
			}
		}
		return false
	}
	
	/** cycle until there is no state change, with the given maximum permitted number of cycles
	 return true if success, false if it stopped because maxCycles reached
	*/
	func cycleUntilStable(client_model : TM, client_controller : TC, maxCycles : Int) -> Bool
	{
		var traversedStates : Set = [currentState.id]
		for cycles in 1...maxCycles
		{
			let changedState = cycleOnce(client_model: client_model, client_controller : client_controller)
			if (!changedState)
			{
				if cycles > 2
				{
					log("executed ", cycles-1, " fsm transitions")
				}
				return true // stable
			}
			else
			{
				traversedStates.insert(currentState.id)
			}
		}
		return false
	}
}
