extends character

#Player variables
var direction : int
onready var gravityDefault : float = gravity

var run_speed = 100
var running : bool = false
var jumpPressedRemeber = 0

func _ready():
	characterName = globals.playerName
	health = globals.playerHealth
	defense = globals.playerDefense
	strength = globals.playerStrength
	mana = globals.playerMana

func _physics_process(delta):
	Engine.time_scale = 1
#	print("Velocity " + self.characterName + ": " + str(velocity))
#	print(pos)
#	print($AnimatedSprite.flip_h)
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	jumpPressedRemeber -= delta
	if jumpPressedRemeber > 0:
		jumpPressedRemeber = 0
		jump()
	
	move(direction)
	
	if get_node("me").on_wall and direction < 0:
		$AnimatedSprite.flip_h = true

func updateSprite(animation : String):
	updateSpriteB(animation)
	if animation == "run" and velocity.y == 0:
		$AnimatedSprite.play("run")
	if animation == "turn":
		if velocity.x < 0:
			$AnimatedSprite.play("turn_right")
		elif velocity.x > 0:
			$AnimatedSprite.play("turn_left")
	if animation == "slide_wall":
		if direction == 0:
			$AnimatedSprite.speed_scale = 5
		else:
			$AnimatedSprite.speed_scale = 1

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
func checkBattle():
	if collide:
		print("collision: " + collide.collider.name)
	if collide and collide.collider.name != "ground":
		loadScene("battle")

#----------------------------------------------------------------------------------