extends Control

var parent
var room

var old_users:Array

func _on_Create_Caracter_pressed():
	$Create_Caracter/Character_creator.show()


func _on_Character_creator_character_created(dict):
	room.rpc("add_character",dict,parent.own_id)
	$Create_Caracter.hide()
