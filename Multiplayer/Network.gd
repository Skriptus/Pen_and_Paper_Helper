extends Node

var seatcount:int = 0
var playerids: Array = [1]
var peer:NetworkedMultiplayerENet
var parent:Node

var own_id = 1

var game_dict:Dictionary
var current_players:int = 0

func start_host(dict:Dictionary):
	game_dict = dict.duplicate()
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(dict["PORT"], dict["Max_players"])
	get_tree().network_peer = peer
	peer.connect("peer_connected",self,"player_connected")
	peer.connect("peer_disconnected",self,"player_disconnected")
	parent.hosting()
	set_network_master(1)
	return Error

func join_game(dict:Dictionary): #get signal from serverlist
	var Error
	game_dict = dict.duplicate()
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(dict["IP"],dict["PORT"])
	get_tree().network_peer = peer
	peer.connect("connection_succeeded",self,"connected")
	peer.connect("connection_failed",self,"failed")
	peer.connect("server_disconnected",self,"kicked")
	yield(peer,"connection_succeeded")
	parent.joined()
	

func player_connected(id):
	rpc("_add_player_id",id)
	current_players += 1
	if current_players >= seatcount:
		peer.refuse_new_connections = false
	parent.room._player_joined(id)
	
func player_disconnected(id):
	rpc("_remove_player_id",id)
	current_players -= 1
	if current_players < seatcount:
		peer.refuse_new_connections = false
	parent.room.rpc("_player_left",id)

func connected():
	print("con")
	set_network_master(1)
	own_id = get_tree().get_network_unique_id()
	
func failed():
	print("Error")
	
func kicked(): #Server disconected clos connection, unload game, load menu
	print("got kicked")
	playerids = [1]
	stop()
	parent.room.queue_free()
	var menu = preload("res://Menu_UI/Main_Menu.tscn").instance()
	parent.add_child(menu)

func stop(): # close connection if existend
	if peer != null:
		peer.close_connection()
		peer = null

sync func _add_player_id(id):
	playerids.append(id)

sync func _remove_player_id(id):
	playerids.remove(playerids.find(id))
