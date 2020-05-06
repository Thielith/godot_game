extends KinematicBody2D
class_name character

onready var velocity : Vector2 = Vector2(0 ,0)
const FLOOR = Vector2(0, -1)
onready var gravity = globals.gravity

onready var pos = get_position()
onready var speed_change : int = 8

onready var walk_speed : int = 100
onready var run_speed : int = 200
onready var max_speed : int = walk_speed
const jump_force : int = -500
var isJumping : bool = false

onready var ground_raycast = $OnFloorRaycast
onready var floor_raycasts = [$LeftFloorRaycast, $RightFloorRaycast]
var snap : Vector2 = Vector2(0, 32)
var slope_direction : int = 0
var wasOnSlope : bool = false

onready var stateMachine = get_node("StateMachine")
onready var animationPlayer = get_node("AnimationPlayer")
onready var playback = stateMachine.get("parameters/playback")

# Constants for state machine
const idle = "idle"
const walking = "walk"
const jumping = "jump"
const falling = "fall"

onready var currentState

func _ready():
	playback.start("idle")
	stateMachine.active = true

func _process(delta):
	_state_process()

func _state_process():
	currentState = playback.get_current_node()
	updateAnimation(currentState)
	match playback.get_current_node():
		idle:
			if velocity.x != 0:
				playback.travel(walking)
			return
		walking:
			if velocity.x == 0:
				playback.travel(idle)
			return
		jumping:
			if velocity.y > 0:
				isJumping = false
				playback.travel(falling)
			elif velocity.y == 0:
				if ground_raycast.is_colliding() or is_on_floor():
					isJumping = false
					playback.travel(idle)
			return
		falling:
			if velocity.y == 0 or slope_direction != 0:
				playback.travel(idle)
			return

func enableGravity(delta):
	pos = get_position()
	if ground_raycast.is_colliding():
		wasOnSlope = false
	
	if currentState != jumping:
		snap = Vector2(0, 32)
	else:
		snap = Vector2.ZERO
	
	slope_direction = int($RightFloorRaycast.is_colliding()) - int($LeftFloorRaycast.is_colliding())
	
	if slope_direction == 0 or currentState == jumping:
		velocity.y += gravity
	else:
		if not ground_raycast.is_colliding():
			wasOnSlope = true
		
		if _get_slope_deg() < 27:
			velocity.y += 5
		elif _get_slope_deg() < 46:
			velocity.y += 7
			if velocity.x == 0 and not isJumping:
				velocity.y = 0
		elif _get_slope_deg() < 64:
			if velocity.x > 0 and slope_direction > 0 or velocity.x < 0 and slope_direction < 0:
				if ground_raycast.is_colliding():
					velocity.x = 0
			elif velocity.y < 500:
				velocity.y += 50
	
	velocity = move_and_slide_with_snap(velocity, snap, FLOOR, true)

var lastAnimation : String
func updateAnimation(animation : String):
	if animation != lastAnimation and animation != null:
		animationPlayer.play(animation)
		lastAnimation = animation

func move(direction):
	#moving idrection of slope, then dont do damp
	if direction != 0 or not direction == 0 and wasOnSlope or direction ^ int(velocity.x) < 0:
		if velocity.x < max_speed * direction:
			velocity.x += speed_change
		elif velocity.x > max_speed * direction:
			velocity.x -= speed_change
	elif direction == 0 and not wasOnSlope:
		if velocity.x > 0:
			velocity.x -= 20
			if velocity.x < 0:
				velocity.x = 0
		if velocity.x < 0:
			velocity.x += 20
			if velocity.x > 0:
				velocity.x = 0
func jump():
	velocity.y = jump_force
	isJumping = true
	playback.travel(jumping)
func launch(launch_x, launch_y):
	if launch_x != null:
		velocity.x = launch_x
	if launch_y != null:
		velocity.x = launch_y

func _get_slope_deg():
	var slopeAngle : float = 0
	if slope_direction > 0:
		slopeAngle = $RightFloorRaycast.get_collision_normal().angle_to(Vector2.UP)
	elif slope_direction < 0:
		slopeAngle = $LeftFloorRaycast.get_collision_normal().angle_to(Vector2.UP)
	return rad2deg(slopeAngle)
#----------------------------------------------------------------------------------