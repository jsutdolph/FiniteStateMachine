//
//  FSM.swift
//
//  A Generic Finite State Machine
//
//  Important Feature: All states can be completely specified in a static array
//
// James Sutton
// jrs@jmsutton.co.uk
//

import Foundation

/**
	a state for a Finite State Machine
*/
class State<StateValue, T>
{
	let id : StateValue
	let transitions: [Transition<StateValue, T>]
	
	/**
	id a unique id for the state
	transitions a set of transitions which can take the FSM to a different state
	*/
	init(_ id: StateValue, transitions: [Transition<StateValue, T>])
	{
		self.id = id
		self.transitions = transitions
	}
	
	func findFirstTransition(client : T) -> Transition<StateValue, T>?
	{
		for transition in transitions
		{
			if (transition.condition(client)) // we return the _first_ transition with true condition - ignore others
			{
				return transition
			}
		}
		return nil
	}
}

/**
	a transition between states
*/
class Transition<StateValue, T>
{
	let condition : (T) -> Bool
	let action : (T) -> Void
	let toStateId : StateValue
	
	/**
	condition a condition for the transition (return true to make the transition)
	action a function to perform on making the transition
	toStateId the new state to arrive at after the transition
	*/
	init(_ condition: @escaping (T) -> Bool, action: @escaping (T) -> Void, toStateId: StateValue)
	{
		self.condition = condition
		self.action = action
		self.toStateId = toStateId
	}
}

/**
	A Finite State Machine
*/
class FSM<StateValue : Hashable, T>
{
	let states : [StateValue : State<StateValue, T>]
	var currentState : State<StateValue, T>
	
	init(states : [State<StateValue, T>], initialStateId : StateValue)
	{
		var statesMap = [StateValue : State<StateValue, T>]()
		for state in states {
			statesMap[state.id] = state
		}
		self.states = statesMap
		self.currentState = statesMap[initialStateId]!
		assert(check())
		print(states.count, " states in FSM")
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
	func cycleOnce(client : T) -> Bool
	{
		if let transition = currentState.findFirstTransition(client: client) { // find a transition with true condition
			transition.action(client) // perform its action
			let newState = states[transition.toStateId]! // move to new state - run-time error if state does not exist
			if newState.id != currentState.id
			{
				print("  change from ", String(describing:currentState.id), " to ", String(describing:newState.id))
				currentState = newState // change state
				return true
			}
		}
		return false
	}
	
	/** cycle until there is no state change, with the given maximum permitted number of cycles
	 return true if success, false if it stopped because maxCycles reached
	*/
	func cycleUntilStable(client : T, maxCycles : Int) -> Bool
	{
		var traversedStates : Set = [currentState.id]
		for cycles in 1...maxCycles
		{
			let changedState = cycleOnce(client: client)
			if (!changedState)
			{
				if cycles > 2
				{
					print("executed ", cycles-1, " fsm transitions")
				}
				return true // stable
			}
			else
			{
				assert(!traversedStates.contains(currentState.id)) // ensure we don't traverse the same state twice to guard against looping
				traversedStates.insert(currentState.id)
			}
		}
		return false
	}
}
