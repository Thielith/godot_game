extends character

#Player variables
var direction : int

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
#	print("Velocity " + self.characterName + ": " + str(velocity))
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	jumpPressedRemeber -= delta
	if jumpPressedRemeber > 0:
		jumpPressedRemeber = 0
		jump()
	
	if direction < 0:
		move("left")
	elif direction > 0:
		move("right")
	elif direction == 0:
		move("")

func updateSprite(animation : String):
	updateSpriteB(animation)
	if animation == "run" and velocity.y == 0:
		$AnimatedSprite.play("run")
	if animation == "turn":
		if velocity.x < 0:
			$AnimatedSprite.play("turn_right")
		elif velocity.x > 0:
			$AnimatedSprite.play("turn_left")

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