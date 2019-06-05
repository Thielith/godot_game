extends character
class_name enemy

onready var player = get_parent().get_node("player")
var eye_reach : int = 10
var visionRange : int = 180
var attackRange : int = 60

var patrolArea : Array
var direction : int

func _ready():
	characterName = globals.enemyName
	health = globals.enemyHealth
	defense = globals.enemyDefense
	strength = globals.enemyStrength
	mana = globals.enemyMana

func _physics_process(delta):
	if velocity.x < 0:
		$AnimatedSprite.flip_h = false
	if velocity.x > 0:
		$AnimatedSprite.flip_h = true
#	print("Velocity " + self.characterName + ": " + str(velocity))

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

func patrol():
	if direction > 0 and pos.x > patrolArea[1].x:
		direction = -1
	if direction < 0 and pos.x < patrolArea[0].x:
		direction = 1
	move(direction)

func updateSprite(animation : String):
	updateSpriteB(animation)
