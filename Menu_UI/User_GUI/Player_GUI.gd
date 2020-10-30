extends Control

var parent
var room

var old_users:Array

func _ready():
	$Create_Caracter/Character_creator.parent = parent
	$Create_Caracter/Character_creator.room = room

func _on_Create_Caracter_pressed():
	$Create_Caracter/Character_creator.show()
