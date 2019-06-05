extends character

#Player variables
var direction : int
onready var gravityDefault : float = gravity

var run_speed = 100
var running : bool = false
var jumpPressedRemeber = 0

var currentState

func _ready():
	characterName = globals.playerName
	health = globals.playerHealth
	defense = globals.playerDefense
	strength = globals.playerStrength
	mana = globals.playerMana
	
	playback = animationTree.get("parameters/playback")
	playback.start("idle")
	animationTree.active = true

func _physics_process(delta):
	enableGravity(delta)
	move(direction)
	jumpPressedRemeber -= delta
	if jumpPressedRemeber > 0:
		jumpPressedRemeber = 0
		jump()

func _process(delta):
	_input_process()
	_state_process()

func _input_process():
	direction = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if Input.is_action_just_pressed("jump"):
		jump()
	if Input.is_action_pressed("run") and not ["idle_crouch", "walk_crouch"].has(currentState):
		max_speed = run_speed
	else:
		max_speed = walk_speed

func _state_process():
	currentState = playback.get_current_node()
	match playback.get_current_node():
		"idle":
			if Input.is_action_pressed("ui_down"):
				playback.travel("idle_crouch")
		"idle_crouch":
			if velocity.x != 0:
				playback.travel("walk_crouch")
			if not Input.is_action_pressed("ui_down"):
				playback.travel("idle")
		"walk":
			if Input.is_action_pressed("ui_down"):
				playback.travel("walk_crouch")
			if Input.is_action_pressed("run"):
				playback.travel("run")
		"walk_crouch":
			if velocity.x == 0:
				playback.travel("idle_crouch")
			if not Input.is_action_pressed("ui_down"):
				playback.travel("walk")
		"run":
			if not Input.is_action_pressed("run"):
				playback.travel("walk")
			if velocity.x == 0:
				playback.travel("idle")
			if velocity.y < 0:
				playback.travel("jump")
			if velocity.y > 0:
				playback.travel("fall_ledge")
		"fall_ledge":
			if velocity.y == 0:
				playback.travel("idle")
		"slide_wall":
			pass
		"jump_wall":
			pass

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