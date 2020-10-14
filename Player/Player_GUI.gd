extends Control

onready var player_info = $Player_Info
var parent = Network.parent
var room

var old_users:Array

onready var Lobby = $Lobby

func _ready():
	Network.connect("update_gui",self,"_update_gui")
	player_info.parent = parent
	parent.player_info = player_info
	player_info.set_name_number(parent.Nickname_doc.doc_fields["Name"],parent.Nickname_doc.doc_fields["Number"])
	player_info.set_level_progress(parent.User_doc.doc_fields["Experience"],true)
	if not is_network_master():
		$Create_Caracter.show()
	else:
		_update_gui()

func _update_gui():
	if Network.host_info && Lobby.Host.get_child_count() == 0:
		var Lobby_host = preload("res://Player/Lobby_player.tscn").instance()
		Lobby.Host.add_child(Lobby_host)
		Lobby_host.fill("res://icon.png",Network.host_info[1]["Name"],String(Network.host_info[2]["Experience"]/50))
		
	for User in Network.User_info_array:
		var skip = false
		for usr in old_users:
			if usr[0] == User[0] || skip:
				skip = true
				if usr[1].Nametext != User[1]["Name"]:
					usr[1].fill("res://icon.png",User[1]["Name"],String(User[2]["Experience"]/50))
		if skip:
			continue
		var Lobby_player = preload("res://Player/Lobby_player.tscn").instance()
		Lobby.Users.add_child(Lobby_player)
		Lobby_player.fill("res://icon.png",User[1]["Name"],String(User[2]["Experience"]/50))
		old_users.append([User[0],Lobby_player])
	var connected_users:Array
	for User in Network.User_info_array:
		connected_users.append(User[0])
	for usr in old_users:
		if connected_users.has(usr[0]):
			continue
		else:
			usr[1].queue_free()
			old_users.remove(old_users.find(usr))
