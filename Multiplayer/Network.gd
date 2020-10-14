extends Node

signal update_gui

var seatcount:int = 0
var peer:NetworkedMultiplayerENet
var parent:Node

var own_id = 1

var game_dict:Dictionary
var current_players:int = 0

sync var User_info_array = [] setget _set_user_info
sync var host_info setget _set_host

func start_host(dict:Dictionary):
	game_dict = dict.duplicate()
	host_info = [own_id,parent.Nickname_doc.doc_fields,parent.User_doc.doc_fields]
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(dict["PORT"], dict["Max_players"])
	get_tree().network_peer = peer
	peer.connect("peer_connected",self,"player_connected")
	peer.connect("peer_disconnected",self,"player_disconnected")
	parent.host_joined()
	set_network_master(1)
	parent.update_status("hosting")
	yield(parent,"status_updated")
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
	parent.update_status("in-game")
	yield(parent,"status_updated")
	parent.host_joined()
	

func player_connected(id):
	current_players += 1
	if current_players >= seatcount:
		peer.refuse_new_connections = false
	parent.room._player_joined(id)
	rset_id(id,"host_info",host_info)
	upadte_game()
	
func player_disconnected(id):
	current_players -= 1
	if current_players < seatcount:
		peer.refuse_new_connections = false
	parent.room.rpc("_player_left",id)
	for User in User_info_array:
		if id == User[0]:
			User_info_array.remove(User_info_array.find(User))
			rset("User_info_array",User_info_array)
	upadte_game()

func connected():
	print("con")
	set_network_master(1)
	own_id = get_tree().get_network_unique_id()
	rpc_id(1,"new_user_info",own_id,parent.Nickname_doc.doc_fields,parent.User_doc.doc_fields)
	
func failed():
	print("Error")
	
func kicked(): #Server disconected clos connection, unload game, load menu
	print("got kicked")
	User_info_array = []
	host_info = null
	stop()
	parent.room.queue_free()
	var menu = preload("res://Menu_UI/Main_Menu.tscn").instance()
	parent.add_child(menu)
	parent.update_status("online")
	yield(parent,"status_updated")

func stop(): # close connection if existend
	if peer != null:
		peer.close_connection()
		peer = null	

func upadte_game():
	game_dict["current_players"] = current_players
	Collections.update_game(game_dict["Name"],game_dict)
	var _game = yield(Collections,"got_game")
	game_dict = _game.fields2dict(_game)

master func new_user_info(id,Nickname,User):
	User_info_array.append([id,Nickname,User])
	rset("User_info_array",User_info_array)

func _set_user_info(new_array):
	User_info_array = new_array
	emit_signal("update_gui")

func _set_host(host):
	host_info = host
	emit_signal("update_gui")
