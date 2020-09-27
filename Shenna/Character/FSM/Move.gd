extends Node

var fsm: StateMachine

func enter():
	pass

func exit(next_state):
	fsm.change_to(next_state)

func interact(type):
	exit("Idle")
