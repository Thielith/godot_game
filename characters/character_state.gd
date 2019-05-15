extends stateMachine
class_name character_state

func _ready():
	add_state("idle")
	add_state("walking")
	add_state("jumping")
	add_state("falling")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.enableGravity(delta)
	
#	print("State: " + str(state))
#	print("Previous State: " + str(previous_state))
#	print("--------------------------------")

func _get_transitionB(delta):
	match state:
		states.idle:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x != 0:
				return states.walking
		
		states.walking:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x == 0:
				return states.idle
		
		states.jumping:
			if parent.on_ground and parent.velocity.y == 0:
				return states.idle
			elif parent.velocity.y > 0:
				return states.falling
		
		states.falling:
			if parent.on_ground and parent.velocity.y == 0:
				return states.idle
			elif parent.velocity.y < 0:
				return states.jumping
	

func _enter_stateB(new_state, old_state):
	match new_state:
		states.idle:
			parent.updateSprite("idle")
		states.walking:
			parent.updateSprite("walk")
		states.jumping:
			parent.updateSprite("jump")
		states.falling:
			parent.updateSprite("fall")

func _exit_state(old_state, new_state):
	pass