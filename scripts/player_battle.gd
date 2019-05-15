extends character

#Player variables
const stopSpeed : int = 10

const jump_force : int = -400

var playerPos : Vector2
var completeAttack : bool = true
var hit : bool = false
var myTurn : bool = true
var beginAction : bool = false
var block = false

func _ready():
	characterName = globals.playerName
	health = globals.playerHealth
	defense = globals.playerDefense
	strength = globals.playerStrength
	mana = globals.playerMana

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_physics_processBase(delta)
	playerPos = get_position()

	updateAnimation(["idle"])
	updateAnimationPlayer()

#----------------------------------------------------------------------------------	

func updateAnimationPlayer():
	if velocity.x == 0 and myTurn:
		if beginAction:
			$AnimatedSprite.play("battle_raise_hand")
			yield($AnimatedSprite, "animation_finished")
			$AnimatedSprite.play("battle_lower_hand")
			block = true
			beginAction = false
		elif on_ground and not block:
			$AnimatedSprite.play("battle_idle")
	elif not myTurn:
		$AnimatedSprite.play("idle")

#----------------------------------------------------------------------------------	

func moveToLocation(location : Vector2, direction):
	var travelComplete : bool = false
	while playerPos.x != location.x and playerPos.x <= location.x and direction == "right":
		velocity.x = 150
		yield(get_tree(), "idle_frame")
	while playerPos.x != location.x and playerPos.x >= location.x and direction == "left":
		velocity.x = -150
		yield(get_tree(), "idle_frame")
	if playerPos.x > location.x:
		velocity.x = 0
		playerPos.x = location.x
	elif playerPos.x < location.x:
		velocity.x = 0
		playerPos.x = location.x

	
func jump(x_velocity, jump_force_mod):
	completeAttack = false
	velocity = Vector2(x_velocity, jump_force + jump_force_mod)
	while not completeAttack:
		if collide and collide.collider.name != "TileMap":
			hit = true
		yield(get_tree(), "idle_frame")
	

func checkEnemySpikey():
	if collide and collide.collider.spike == true:
		pass

#----------------------------------------------------------------------------------

func storeStats(battle):
	globals.playerName = characterName
	globals.playerHealth = health
	globals.playerDefense = defense
	globals.playerStrength = strength
	
	globals.enemyName = "enemy name"
	globals.enemyHealth = 10
	globals.enemyDefense = 0
	globals.enemyStrength = 1
func loadScene(sceneName):
	storeStats(true)
	get_tree().change_scene("res://scenes/" + sceneName + ".tscn")
func endBattle():
	loadScene("World")

#----------------------------------------------------------------------------------