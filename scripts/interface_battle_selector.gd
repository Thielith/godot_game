extends Control

onready var attackVisual = get_node("attack")
onready var itemsVisual = get_node("items")
onready var defendVisual = get_node("defend")
onready var runVisual = get_node("run")
onready var animationPlayer = get_node("AnimationPlayer")

var choicesArray : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	choicesArray = [attackVisual, defendVisual, runVisual, itemsVisual]
	print(choicesArray)

func _process(delta):
	pass

func turnUI(direction):
	var currentOption = choicesArray[0]
	if direction == "left":
		if currentOption.name == "attack":
			animationPlayer.play_backwards("defend -> attack")
		elif currentOption.name == "defend":
			animationPlayer.play_backwards("run -> defend")
		elif currentOption.name == "run":
			animationPlayer.play_backwards("items -> run")
		elif currentOption.name == "items":
			animationPlayer.play_backwards("attack -> items")
		choicesArray.push_back(currentOption)
		choicesArray.pop_front()
	elif direction == "right":
		if currentOption.name == "attack":
			animationPlayer.play("attack -> items")
		elif currentOption.name == "defend":
			animationPlayer.play("defend -> attack")
		elif currentOption.name == "run":
			animationPlayer.play("run -> defend")
		elif currentOption.name == "items":
			animationPlayer.play("items -> run")
		currentOption = choicesArray[choicesArray.size() - 1]
		choicesArray.push_front(currentOption)
		choicesArray.pop_back()