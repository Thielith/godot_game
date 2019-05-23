extends character_state

var jumpPressedRemeberTime = 0.2
var canJumpRemeber = 0
var canJumpRemeberTime = 0.2

var on_wall : bool = false
var storedDirection : int

func _ready():
	add_state("running")
	add_state("turning_left")
	add_state("turning_right")
	add_state("crouching")
	add_state("crouch_walking")
	add_state("sliding_wall")

func _physics_process(delta):
	if parent.direction != 0 and parent.velocity.y > 0.01:
		if parent.is_on_wall() or on_wall:
			if parent.direction != storedDirection:
				on_wall = false
			else:
				on_wall = true
				parent.velocity.y = 30
			
	elif parent.velocity.x > 4 or parent.velocity.x < -4:
		on_wall = false
	storedDirection = parent.direction

func _input(event):
	if [states.idle, states.walking, states.running, states.turning_left, states.turning_right].has(state):
		if Input.is_action_pressed("ui_up") and state != states.jumping:
			parent.jumpPressedRemeber = jumpPressedRemeberTime
	
	if Input.is_action_just_pressed("ui_up"):
		canJumpRemeber = canJumpRemeberTime
		if state == states.sliding_wall and parent.direction != 0:
			parent.jump()
			parent.launch(-80 * parent.direction, null)
	
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
				print("not on floor")
				print(canJumpRemeber)
				if parent.velocity.y < 0:
					return states.jumping
				elif parent.velocity.y > 0:
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
		
		states.falling:
			if on_wall:
				return states.sliding_wall
		
		states.sliding_wall:
			if parent.direction == 0:
				parent.get_node("AnimatedSprite").speed_scale = 3
			else:
				parent.get_node("AnimatedSprite").speed_scale = 1
			if parent.velocity.y == 0:
				parent.get_node("AnimatedSprite").speed_scale = 1
				return states.idle
			if parent.velocity.y < 0:
				parent.get_node("AnimatedSprite").speed_scale = 1
				return states.jumping
			if not on_wall:
				parent.get_node("AnimatedSprite").speed_scale = 1
				return states.falling
		
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
		states.sliding_wall:
			parent.updateSprite("slide_wall")
	_enter_stateB(new_state, old_state)

func _exit_state(old_state, new_state):
	pass