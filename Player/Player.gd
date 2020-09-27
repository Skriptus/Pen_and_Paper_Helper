extends Node

class_name player

var game_character:Object

onready var network:Node = $Network
onready var save_load:Node = $Save_Load
onready var mainmenu:Node = $Main_Menu

func _ready():
	network.parent = self
	save_load.parent = self
	mainmenu.parent = self
	
	
	
