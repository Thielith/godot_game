extends character
class_name enemy

onready var player = get_parent().get_node("player")
var eye_reach : int = 10
var visionRange : int = 180
var attackRange : int = 60

var patrolArea : Array = [Vector2(184, 144), Vector2(312, 144)]
var patrol : bool = true
var patrolTurnAround : bool = false

func _ready():
	characterName = globals.enemyName
	health = globals.enemyHealth
	defense = globals.enemyDefense
	strength = globals.enemyStrength
	
	max_speed = 30

func _physics_process(delta):
	patrol()
#	print("Velocity " + self.characterName + ": " + str(velocity))

func patrol():
	if pos.x < patrolArea[1].x and not patrolTurnAround:
		$me.set_state($me.states.walk_right)
	elif pos.x > patrolArea[1].x and not patrolTurnAround:
		$me.set_state($me.states.idle)
		patrolTurnAround = true
	
	if pos.x > patrolArea[0].x and patrolTurnAround:
		$me.set_state($me.states.walk_left)
	elif pos.x < patrolArea[0].x and patrolTurnAround:
		$me.set_state($me.states.idle)
		patrolTurnAround = false

func sees_player():
	var eye_center = pos
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	var player_pos = player.pos
	var player_extents = player.get_node("Vision").shape.extents - Vector2(3, 3)
	var top_left = player_pos +  Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos +  Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos +  Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos +  Vector2(player_extents.x, player_extents.y)
	
	var space_state = get_world_2d().direct_space_state
	
	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if Vector2(abs(pos.x - player.pos.x), abs(pos.y - player.pos.y)) <= Vector2(visionRange, visionRange):
				var collision = space_state.intersect_ray(eye, corner, [], 1)
				if collision and collision.collider.name == "player":
					return true
	return false

func updateSprite(animation : String):
	updateSpriteB(animation)
#	if animation == "run" and velocity.y == 0:
#		$AnimatedSprite.play("run")
