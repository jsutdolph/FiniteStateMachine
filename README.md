# FiniteStateMachine
Finite State Machine

A generic Finite State Machine in Swift

Feature:

All states and transition logic are defined in a static array - you only write code to handle
condition tests and actions for your transitions


Background:

A State is defined by:
1. A unique identifier - usually an enum
2. A set of Transitions

A Transition is defined by:
1. A boolean condition which determines if the transition is taken
2. An action function which is performed when the transition is taken
3. A final State identifier which becomes the new state of the machine after the transition is taken

The State Machine starts in a defined initial state

A protocol is defined for the condition test functions and action functions for the transitions.

All States with their associated Transitions are defined in a static array

The client class implements the protocol, and whenever anything changes it calls fsm.cycleUntilStable()
which automatically handles transitions between states until the state stops changing, and it returns true,
or until it has reached the maximum number of cycles and it returns false

Incidently when cycling it asserts that it is not in a closed loop with more than one state, as this
signals an error in the state definition table.

Code:

FSM.swift - the generic State Machine which you instantiate to handle your set of states

Sample App:

Code is provided for a simple iOS app which implements the (trivial) turnstile described
in https://en.wikipedia.org/wiki/Finite-state_machine

Usage:
This was designed for handling the UI of a music score editing program. It simplifies
the design by separating the complicated state logic from the UI detail, and it is a great
benefit having the states defined explicitly with all permitted transitions, and no nested ifs.
