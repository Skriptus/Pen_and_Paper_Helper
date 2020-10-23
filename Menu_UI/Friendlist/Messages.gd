extends Control

onready var con:TabContainer = $TabContainer

func _ready():
	var new_tab = preload("res://Menu_UI/Friendlist/Messaging/Chat.tscn").instance()
	new_tab.name = "Wow such empty"
	con.add_child(new_tab)
	con.set_tab_disabled(0,true)
