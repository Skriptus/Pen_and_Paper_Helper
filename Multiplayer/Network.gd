extends Node

var seatcount:int = 0
var playerids: Array = []
var peer:NetworkedMultiplayerENet
onready var lobby:Object = $Lobby
var parent:Object

func start_host():
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(4242, seatcount)
	get_tree().network_peer = peer
	peer.connect("peer_connected",self,"player_connected")
	peer.connect("peer_disconnected",self,"player_disconnected")
	return Error

func player_connected(id):
	playerids.append(id)
	if playerids.size() >= seatcount:
		peer.refuse_new_connections = true
	
func player_disconnected(id):
	playerids.remove(playerids.find(id))
	if playerids.size() < seatcount:
		peer.refuse_new_connections = false

func start_client():
	peer = NetworkedMultiplayerENet.new()
	peer.create_client("",4242)
	get_tree().network_peer = peer
	peer.connect("connection_succeeded",self,"connected")
	peer.connect("connection_failed",self,"failed")
	peer.connect("server_disconnected",self,"kicked")

func connected():
	set_network_master(1)
	
func failed():
	print("Error")
	
func kicked():
	print("got kicked")
	lobby.room.free()

func stop():
	if peer != null:
		peer.close_connection()
		peer = null
