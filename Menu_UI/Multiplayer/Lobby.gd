extends VBoxContainer

onready var Host = $Hostcon
onready var Users = $Usercon
var Host_player
var Lobby_users:Array
var parent

func update():
	if not Host_player:
		Host_player = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
		Host.add_child(Host_player)
	if Host.get_child_count() > 0:
		Host_player.fill("res://icon.png",parent.host_info["Name"],parent.host_info["Experience"])
	for Usr in Lobby_users:
		if parent.connected_users.has(Usr):
			continue
		else:
			Users.remove_child(Users.get_node(Usr["Name"]))
			Lobby_users.remove(Lobby_users.find(Usr))
	for Usr in parent.connected_users:
		if Lobby_users.has(Usr):
			continue
		else:
			var user = preload("res://Menu_UI/Multiplayer/Lobby_player.tscn").instance()
			Users.add_child(user)
			user.name = Usr["Name"]
			user.fill("res://icon.png",Usr["Name"],Usr["Experience"])
			Lobby_users.append(Usr)
		
