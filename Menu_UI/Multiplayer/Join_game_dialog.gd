extends Popup

onready var server_list = $Panel/VBoxContainer/ScrollContainer/Serverlist
onready var multiplayer_UI = get_parent()

func list_servers(list):
	for item in list:
		Collections.get_game(item)
		var game = yield(Collections,"got_game")
		var Server = preload("res://Menu_UI/Multiplayer/Server.tscn").instance()
		server_list.add_child(Server)
		Server.fill(game)
		Server.name = game["Name"]
		Server.connect("join_server",self,"join_game")

func join_game(game):
	multiplayer_UI.emit_signal("join_game",game)
	self.hide()
