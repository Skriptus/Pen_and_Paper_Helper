extends Control

var parent
var room

var old_users:Array

onready var Lobby = $Lobby

func _ready():
	parent.connect("update_gui",self,"_update_gui")
	$Create_Caracter/Character_creator.parent = parent
	$Create_Caracter/Character_creator.room = room
	if not is_network_master():
		$Create_Caracter.show()
	_update_gui()

func _update_gui():
	var Lobby_host
	if parent.host_info && Lobby.Host.get_child_count() == 0:
		Lobby_host = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
		Lobby.Host.add_child(Lobby_host)
	Lobby_host.fill("res://icon.png",parent.host_info["Name"],String(parent.host_info["Experience"]/50))
	for Usr in parent.connected_users:
		if old_users.has(Usr):
			continue
		
	


func _on_Create_Caracter_pressed():
	$Create_Caracter/Character_creator.show()
