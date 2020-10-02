extends Node

signal start_host(dict)
signal joined_game(dict)

var seatcount:int = 0
var playerids: Array = []
var peer:NetworkedMultiplayerENet
var parent:Node

var game_dict

func _ready():
	connect("start_host",self,"_start_host")

func _start_host(dict):
	game_dict = dict
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(dict["PORT"], dict["Max_players"])
	get_tree().network_peer = peer
	peer.connect("peer_connected",self,"player_connected")
	peer.connect("peer_disconnected",self,"player_disconnected")
	return Error

func join_game(dict): #get signal from serverlist
	var Error
	game_dict = dict
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(dict["IP"],dict["PORT"])
	get_tree().network_peer = peer
	peer.connect("connection_succeeded",self,"connected")
	peer.connect("connection_failed",self,"failed")
	peer.connect("server_disconnected",self,"kicked")
	
	

func player_connected(id):
	playerids.append(id)
	if playerids.size() >= seatcount:
		peer.refuse_new_connections = true
	
func player_disconnected(id):
	playerids.remove(playerids.find(id))
	if playerids.size() < seatcount:
		peer.refuse_new_connections = false

func connected():
	print("con")
	set_network_master(1)
	emit_signal("joined_game",parent,"joined",game_dict)
	
func failed():
	print("Error")
	
func kicked():
	print("got kicked")

func stop():
	if peer != null:
		peer.close_connection()
		peer = null
