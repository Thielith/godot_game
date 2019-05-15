extends character

#Player variables
var direction : String = ""

var run_speed = 100
var running : bool = false

func _ready():
	characterName = globals.playerName
	health = globals.playerHealth
	defense = globals.playerDefense
	strength = globals.playerStrength
	mana = globals.playerMana

func _physics_process(delta):
#	print("Velocity " + self.characterName + ": " + str(velocity))
	if Input.is_action_pressed("ui_left"):
		move("left")
	elif Input.is_action_pressed("ui_right"):
		move("right")
	else:
		move("")

func updateSprite(animation : String):
	updateSpriteB(animation)
	if animation == "run" and velocity.y == 0:
		$AnimatedSprite.play("run")
	if animation == "slide":
		if velocity.x < 0:
			$AnimatedSprite.play("slide_front")
		elif velocity.x > 0:
			$AnimatedSprite.play("slide_back")

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