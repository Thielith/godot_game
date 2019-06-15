extends KinematicBody2D
class_name character

onready var characterName : String
onready var health : int
onready var defense : int
onready var strength : int
onready var mana : int

onready var velocity : Vector2 = Vector2(0 ,0)
const FLOOR = Vector2(0, -1)
onready var gravity = globals.gravity

onready var collide = move_and_collide(velocity * 0.0001)
onready var pos = get_position()

onready var max_speed : int = 50
onready var walk_speed : int = 50
const jump_force : int = -250

var onGroundRemeber = 0
var onGroundRemeberTime = 0.2
onready var on_ground : bool

onready var animationTree = get_node("AnimationTree")
onready var animationPlayer = get_node("AnimationPlayer")
onready var playback = animationTree.get("parameters/playback")

# Constants for state machine
const idle = "idle"
const walking = "walk"
const jumping = "jump"
const falling = "fall"

func _ready():
	playback.start("idle")
	animationTree.active = true

func _process(delta):
	match playback.get_current_node():
		idle:
			if velocity.x != 0:
				playback.travel(walking)
			if velocity.y < 0:
				playback.travel(jumping)
			return
		walking:
			if velocity.x == 0:
				playback.travel(idle)
			if velocity.y < 0:
				playback.travel(jumping)
			return
		jumping:
			if velocity.y > 0:
				playback.travel(falling)
			if velocity.y == 0 and on_ground:
				playback.travel(idle)
			return
		falling:
			if velocity.y < 0:
				playback.travel(jumping)
			if velocity.y == 0:
				playback.travel(idle)
			return

func enableGravity(delta):
	#Updates Postion
	pos = get_position()
	
	velocity.y += gravity
	velocity = move_and_slide(velocity, FLOOR)
	#Enables collision
	collide = move_and_collide(velocity * 0.0001, false)
	
	onGroundRemeber -= delta
	if is_on_floor():
		onGroundRemeber = onGroundRemeberTime
	if onGroundRemeber > 0:
		on_ground = true
	if not onGroundRemeber > 0:
		on_ground = false

func idle():
	if velocity.y == 0:
		on_ground = true

func move(direction):
	if direction == -1:
		if velocity.x > -max_speed:
			velocity.x -= 4
		elif velocity.x < -max_speed:
			velocity.x += 4
	elif direction == 1:
		if velocity.x < max_speed:
			velocity.x += 4
		elif velocity.x > max_speed:
			velocity.x -= 4
	elif direction == 0:
		if velocity.x > 0:
			velocity.x -= 10
			if velocity.x < 0:
				velocity.x = 0
		if velocity.x < 0:
			velocity.x += 10
			if velocity.x > 0:
				velocity.x = 0

func jump():
	velocity.y = jump_force

func launch(launch_x, launch_y):
	if launch_x != null:
		velocity.x = launch_x
	if launch_y != null:
		velocity.x = launch_y

#----------------------------------------------------------------------------------