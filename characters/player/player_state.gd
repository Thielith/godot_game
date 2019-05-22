extends character_state

var jumpPressedRemeberTime = 0.2
var canJumpRemeber = 0
var canJumpRemeberTime = 0.2

func _ready():
	add_state("running")
	add_state("turning_left")
	add_state("turning_right")
	add_state("crouching")
	add_state("crouch_walking")

func _input(event):
	if [states.idle, states.walking, states.running, states.turning_left, states.turning_right].has(state):
		if Input.is_action_pressed("ui_up") and state != states.jumping:
			parent.jumpPressedRemeber = jumpPressedRemeberTime
	
	if Input.is_action_just_pressed("ui_up"):
		canJumpRemeber = canJumpRemeberTime
	
	if Input.is_action_just_pressed("ui_down"):
		parent.get_node("CollisionStand").disabled = true
		parent.get_node("CollisionCrouch").disabled = false
	if Input.is_action_just_released("ui_down"):
		parent.get_node("CollisionStand").disabled = false
		parent.get_node("CollisionCrouch").disabled = true
		
	if Input.is_action_pressed("run"):
		parent.max_speed = parent.run_speed
		parent.running = true
	else:
		parent.max_speed = parent.walk_speed
		parent.running = false
	
	

func _get_transition(delta):
	canJumpRemeber -= delta
	match state:
		states.idle:
			if parent.velocity.x != 0:
				if parent.running:
					return states.running
			if Input.is_action_just_pressed("ui_down"):
				return states.crouching
		
		states.walking:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			if parent.running:
				return states.running
			if Input.is_action_just_pressed("ui_down"):
				return states.crouch_walking
		
		states.running:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					if canJumpRemeber > 0:
						canJumpRemeber = 0
						return states.falling
			elif not parent.running:
				return states.walking
			elif parent.velocity.x == 0:
				return states.idle
			elif parent.direction > 0 and parent.velocity.x < 0:
				return states.turning_left
			elif parent.direction < 0 and parent.velocity.x > 0:
				return states.turning_right
		
		states.turning_left:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x >= 0:
				return states.idle
			elif parent.direction < 0:
				return states.running
		
		states.turning_right:
			if not parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
					return states.falling
			elif parent.velocity.x <= 0:
				return states.idle
			elif parent.direction > 0:
				return states.running
		
		states.crouching:
			if Input.is_action_just_released("ui_down"):
				return states.idle
			elif parent.velocity.x != 0:
				return states.crouch_walking
		
		states.crouch_walking:
			if Input.is_action_just_released("ui_down"):
				return states.walking
			if parent.velocity.x == 0:
				return states.crouching
		
	return _get_transitionB(delta)

func _enter_state(new_state, old_state):
	match new_state:
		states.running:
			parent.updateSprite("run")
		states.turning_left:
			parent.updateSprite("turn")
		states.turning_right:
			parent.updateSprite("turn")
		states.crouching:
			parent.updateSprite("crouch")
		states.crouch_walking:
			parent.updateSprite("crouch_walk")
	_enter_stateB(new_state, old_state)

func _exit_state(old_state, new_state):
	pass