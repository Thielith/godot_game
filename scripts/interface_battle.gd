extends Control

onready var actionSelector = get_node("menu/choices")
onready var textImage = get_node("menu/textImage")
var attackText = preload("res://sprites/hud/attack.png")
var defendText = preload("res://sprites/hud/defend.png")
var runText = preload("res://sprites/hud/run.png")
var itemsText = preload("res://sprites/hud/items.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		actionSelector.turnUI("left")
		updateTextImage()
	if Input.is_action_just_pressed("ui_right"):
		actionSelector.turnUI("right")
		updateTextImage()

func updateTextImage():
	if actionSelector.choicesArray[0].name == "attack":
		textImage.set_texture(attackText)
	elif actionSelector.choicesArray[0].name == "defend":
		textImage.set_texture(defendText)
	elif actionSelector.choicesArray[0].name == "run":
		textImage.set_texture(runText)
	elif actionSelector.choicesArray[0].name == "items":
		textImage.set_texture(itemsText)