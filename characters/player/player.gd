extends character

#Player variables
var direction : int
onready var gravityDefault : float = gravity

var jumpPressedRemeber = 0

onready var left_wall_raycasts = [$LeftWallRaycastTop, $LeftWallRaycastBottom]
onready var right_wall_raycasts = [$RightWallRaycastTop, $RightWallRaycastBottom]
var wall_direction : int = 0
var wallJumpEnabled : bool = true

# Constants for state machine
const idle_crouch = "idle_crouch"
const walking_crouch = "walk_crouch"
const running = "run"
const falling_ledge = "fall_ledge"
const sliding_wall = "slide_wall"
const jumping_wall = "jump_wall"

func _ready():
	pass

func _physics_process(delta):
	enableGravity(delta)
	
	if currentState != sliding_wall:
		move(direction)
	
	jumpPressedRemeber -= delta
	if jumpPressedRemeber > 0:
		jumpPressedRemeber = 0
		jump()
	
	_update_wall_direction()
	if currentState == sliding_wall and velocity.y > 0:
		velocity.y = globals.gravity * 3
	else:
		gravity = globals.gravity
	if Input.is_action_pressed("ui_down") and [sliding_wall, falling].has(currentState):
		launch(-100 * wall_direction, null)
		wallJumpSwitch(false)
	if direction != 0 and not wallJumpEnabled:
		wallJumpSwitch(true)
func _process(delta):
	_input_process()
	_state_process()
	
	if velocity.x < 0:
		$Sprite.set_texture(preload("res://characters/player/player_left.png"))
	elif velocity.x > 0:
		$Sprite.set_texture(preload("res://characters/player/player_right.png"))

func _input_process():
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if Input.is_action_just_pressed("jump") and [idle, walking, running, sliding_wall].has(currentState):
		jump()
		if currentState == sliding_wall:
			launch(360 * -wall_direction, null)
	if Input.is_action_pressed("run") and not [idle_crouch, walking_crouch].has(currentState):
		max_speed = run_speed
	else:
		max_speed = walk_speed
func _state_process():
	currentState = playback.get_current_node()
#	print(_check_if_slope())
	if Input.is_action_pressed("interact"):
		print(currentState)
#		print(wall_direction)
	match playback.get_current_node():
		idle:
			if Input.is_action_pressed("ui_down"):
				playback.travel(idle_crouch)
			if velocity.y > 0:
				playback.travel(falling_ledge)
			return
		idle_crouch:
			if velocity.x != 0:
				playback.travel(walking_crouch)
			if Input.is_action_just_released("ui_down"):
				playback.travel(idle)
			if velocity.y > 20.005:
				playback.travel(falling_ledge)
			return
		walking:
			if Input.is_action_pressed("ui_down"):
				playback.travel(walking_crouch)
			if Input.is_action_pressed("run"):
				playback.travel(running)
			if velocity.y > 0 and not on_ground and not _check_if_slope():
				playback.travel(falling_ledge)
			return
		walking_crouch:
			if velocity.x == 0:
				playback.travel(idle_crouch)
			if Input.is_action_just_released("ui_down"):
				playback.travel(walking)
			if velocity.y > 20.005 and not is_on_floor():
				playback.travel(falling_ledge)
			return
		running:
			if Input.is_action_just_released("run"):
				playback.travel(walking)
			if velocity.x == 0:
				playback.travel(idle)
			if velocity.y < 0 and not is_on_floor() and not _check_if_slope():
				playback.travel(jumping)
			if velocity.y > 0 and not is_on_floor() and not _check_if_slope():
				playback.travel(falling_ledge)
			return
		jumping:
			if wall_direction != 0 and direction == wall_direction:
				playback.travel(sliding_wall)
			return
		falling:
			if wall_direction != 0 and direction == wall_direction:
				playback.travel(sliding_wall)
			return
		falling_ledge:
			if velocity.y < 0:
				playback.travel(jumping)
			if velocity.y == 0 or _check_if_slope():
				playback.travel(idle)
			if wall_direction != 0 and direction == wall_direction:
				playback.travel(sliding_wall)
			return
		sliding_wall:
			wallJumpExtendRaycast(true, wall_direction)
			if on_ground and velocity.y == 0:
				wallJumpExtendRaycast(false, 0)
				playback.travel(idle)
			elif wall_direction == 0:
				wallJumpExtendRaycast(false, 0)
				playback.travel(falling)
			elif Input.is_action_just_pressed("jump"):
				wallJumpExtendRaycast(false, 0)
				playback.travel(jumping_wall)
			elif Input.is_action_pressed("ui_down"):
				print("player")
				wallJumpExtendRaycast(false, 0)
				playback.travel(falling)
			return
		jumping_wall:
			if velocity.y > 0:
				playback.travel(falling)
			if velocity.y == 0:
				if on_ground:
					playback.travel(idle)
				elif wall_direction != 0:
					playback.travel(sliding_wall)
				elif not on_ground:
					playback.travel(falling)
			return

func _check_is_valid_wall(wall_raycasts : Array):
	for raycast in wall_raycasts:
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI*0.55:
				return true
	return false
func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left and is_near_wall_right:
		wall_direction = direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
func wallJumpSwitch(enabled : bool):
	if enabled:
		for raycast in left_wall_raycasts:
			raycast.enabled = true
		for raycast in right_wall_raycasts:
			raycast.enabled = true
		wallJumpEnabled = true
	elif not enabled:
		for raycast in left_wall_raycasts:
			raycast.enabled = false
		for raycast in right_wall_raycasts:
			raycast.enabled = false
		wallJumpEnabled = false
func wallJumpExtendRaycast(arg : bool, direction : int):
	if arg:
		if direction < 0:
			for raycast in left_wall_raycasts:
				raycast.cast_to.x = -20
		elif direction > 0:
			for raycast in right_wall_raycasts:
				raycast.cast_to.x = 20
	elif not arg:
		for raycast in left_wall_raycasts:
			raycast.cast_to.x = -2
		for raycast in right_wall_raycasts:
			raycast.cast_to.x = 2

#----------------------------------------------------------------------------------

func storeStats(battle):
	globals.playerName = characterName
	globals.playerHealth = health
	globals.playerDefense = defense
	globals.playerStrength = strength
	
	if battle:
		globals.enemyName = characterName
		globals.enemyHealth = health
		globals.enemyDefense = defense
		globals.enemyStrength = strength
func loadScene(sceneName):
	if sceneName == "battle":
		storeStats(true)
	else:
		storeStats(false)
	get_tree().change_scene("res://scenes/" + sceneName + ".tscn")
#func checkBattle():
#	if collide:
#		print("collision: " + collide.collider.name)
#	if collide and collide.collider.name != "ground":
#		loadScene("battle")

#----------------------------------------------------------------------------------