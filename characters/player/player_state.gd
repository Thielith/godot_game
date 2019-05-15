extends character_state

var jumpPressedRemeber = 0
var jumpPressedRemeberTime = 0.2

func _ready():
	add_state("running")
	add_state("sliding_left")
	add_state("sliding_right")
#	add_state("crouch")

func _input(event):
	if [states.idle, states.walking, states.running, states.sliding_left, states.sliding_right].has(state):
		if event.is_action_pressed("ui_up") and state != states.jumping:
			parent.jump()
#		jumpPressedRemeber -= delta
#		if event.is_action_just_pressed("ui_up") and state != states.jumping:
#			jumpPressedRemeber = jumpPressedRemeberTime
#		if jumpPressedRemeber > 0:
#			jumpPressedRemeber = 0
#			set_state(states.jumping)
		
	if Input.is_action_pressed("run"):
		parent.max_speed = parent.run_speed
		parent.running = true
	else:
		parent.max_speed = parent.walk_speed
		parent.running = false
	
	

func _get_transition(delta):
	match state:
		states.idle:
			if parent.velocity.x != 0:
				if parent.running:
					return states.running
		
		states.walking:
			if parent.running:
				return states.running
		
		states.running:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif not parent.running:
				return states.walking
			elif parent.velocity.x == 0:
				return states.idle
			elif Input.is_action_pressed("ui_right") and parent.velocity.x < 0:
				return states.sliding_left
			elif Input.is_action_pressed("ui_left") and parent.velocity.x > 0:
				return states.sliding_right
		
		states.sliding_left:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x == 0:
				return states.idle
			elif parent.velocity.x == -parent.max_speed:
				return states.running
		
		states.sliding_right:
			print("right")
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x == 0:
				return states.idle
			elif parent.velocity.x == parent.max_speed:
				return states.running
		
	return _get_transitionB(delta)

func _enter_state(new_state, old_state):
	match new_state:
		states.running:
			parent.updateSprite("run")
		states.sliding_left:
			parent.updateSprite("slide")
		states.sliding_right:
			parent.updateSprite("slide")
	_enter_stateB(new_state, old_state)

func _exit_state(old_state, new_state):
	pass