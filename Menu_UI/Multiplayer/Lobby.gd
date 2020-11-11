extends VBoxContainer

onready var Host = $Hostcon
onready var Users = $Usercon
var Host_player
var Lobby_users:Array
var parent
var room

func update():
	if not Host_player:
		Host_player = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
		Host.add_child(Host_player)
	if Host.get_child_count() > 0:
		Host_player.fill("res://icon.png",room.host["Name"],room.host["Experience"])
	for Usr in Lobby_users:
		if room.Players_dict.keys().has(Usr):
			continue
		else:
			Users.remove_child(Users.get_node(Usr["Name"]))
			Lobby_users.remove(Lobby_users.find(Usr))
	for Usr in room.Players_dict.keys():
		if Lobby_users.has(Usr) || Usr == 1:
			continue
		else:
			var user = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
			Users.add_child(user)
			user.name = String(Usr)
			print(room.Players_dict)
			user.fill("res://icon.png",room.Players_dict[Usr][2]["Name"],room.Players_dict[Usr][2]["Experience"])
			Lobby_users.append(Usr)
		
