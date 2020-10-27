extends Popup

onready var server_list = $Panel/VBoxContainer/ScrollContainer/Serverlist
onready var multiplayer_UI = get_parent()

func list_servers(list):
	for item in list:
		Collections.get_game(item)
		var game = yield(Collections,"got_game")
		var Server = preload("res://Menu_UI/Multiplayer/Server.tscn").instance()
		server_list.add_child(Server)
		Server.fill(game.doc_fields)
		Server.name = game.doc_fields["Name"]
		Server.connect("join_server",get_tree().get_root(),"join_game")
