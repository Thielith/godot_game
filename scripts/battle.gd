extends Node2D

onready var currentChoice = get_node("Interface").actionSelector.choicesArray[0].name
onready var animationPlayer = get_node("Interface/AnimationPlayer")
onready var timer = get_node("Interface/Timer")
onready var player = get_node("Player")
onready var playerSprite = get_node("Player/AnimatedSprite")
onready var enemy = get_node("slime")
const playerDefaultPos : Vector2 = Vector2(40, 192)
const playerCloseEnemy : Vector2 = Vector2(280, 192)
const enemyDefaultPos : Vector2 = Vector2(344, 192)
var attacking : bool = false
var maxCombo : int = 0
var combo : int = 0
var timedPress : bool = false
var comboCheck : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#If player presses interact key
	if Input.is_action_just_pressed("interact") and not attacking:
		#If attack choosen
		if currentChoice == "attack":
			#Specific code for jump attack
			attacking = true
			maxCombo = 1
			print("attack selected")
			player.beginAction = true
			yield(playerSprite, "animation_finished")
			animationPlayer.play("menu_slide_out")
			yield(animationPlayer, "animation_finished")
			player.moveToLocation(playerCloseEnemy, "right")
			while player.playerPos.x != playerCloseEnemy.x:
				yield(get_tree(), "idle_frame")
			player.jump(50, 0)
			while not comboCheck:
				if player.hit:
					dealDamage(player, enemy)
				comboCheck()
				if timedPress and player.hit:
					player.jump(0, 150)
					player.hit = false
					timedPress = false
				yield(get_tree(), "idle_frame")
			maxCombo = 0
			combo = 0
			timedPress = false
			player.velocity.y = -200
			$Player/AnimatedSprite.flip_h = true
			player.moveToLocation(playerDefaultPos, "left")
			while player.playerPos.x != playerDefaultPos.x:
				yield(get_tree(), "idle_frame")
			$Player/AnimatedSprite.flip_h = false
			player.myTurn = false

func comboCheck():
	if Input.is_action_just_pressed("interact") and not player.hit:
		print("success combo")
		timedPress = true
	if combo < maxCombo and timedPress and player.hit:
		combo += 1
	elif not combo > maxCombo and player.hit:
		comboCheck = true

func dealDamage(attacker, attackee):
	attackee.health -= attacker.strength
	print(str(attackee.name) + " took damage")

func enemyAttack():
	var attackChoice = randi()%2
	if attackChoice >= 0:
		pass
