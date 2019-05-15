extends Node

var playerName : String = "name"
var playerHealth : int = 10
var playerDefense : int = 0
var playerStrength : int = 1
var playerMana : int = 10

var enemyName : String = "enemy name"
var enemyHealth : int = 10
var enemyDefense : int = 0
var enemyStrength : int = 1

func _ready():
	randomize()