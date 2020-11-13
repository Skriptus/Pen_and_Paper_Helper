extends VBoxContainer

onready var Host = $Hostcon
onready var Users = $Usercon
var room

func update():
	if Host.get_child_count() == 0:
		var Host_player = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
		Host.add_child(Host_player)
	if Host.get_child_count() > 0:
		Host.get_child(0).fill("res://icon.png",room.Players_dict[1][2]["Name"],room.Players_dict[1][2]["Experience"])
	for Usr in Users.get_children():
		if room.Players_dict.keys().has(Usr.name):
			continue
		else:
			Users.remove_child(Users.get_node(Usr.name))
	for Usr in room.Players_dict.keys():
		var skip = false
		for child in Users.get_children():
			if room.Players_dict.keys().has(child.name):
				skip = true
				break
		if skip:
			continue
		else:
			var user = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
			Users.add_child(user)
			user.name = String(Usr)
			user.fill("res://icon.png",room.Players_dict[Usr][2]["Name"],room.Players_dict[Usr][2]["Experience"])
