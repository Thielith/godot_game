extends character_state

func _ready():
	pass
#	add_state("run_left")

func _get_transition(delta):
	_get_transitionB(delta)
#	match state:
#		states.run_left:
#			if parent.running:
#				return states.run_left
#			else:
#				set_state(states.walk_left)
#				return states.walk_left
#	return null

func _enter_state(new_state, old_state):
#	match new_state:
#		states.run_left:
#			if old_state == states.idle or states.walk_left or states.run_left or states.slide_right:
#				if old_state != states.fall:
#					parent.updateSprite("run", true)
	_enter_stateB(new_state, old_state)

func _exit_state(old_state, new_state):
	pass