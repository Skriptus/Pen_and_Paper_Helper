extends Node

signal status_updated

var game_character:Object
var IPAddress:String
var email:String

onready var player_info = $CanvasLayer/Player_Info
onready var current_menu = $CanvasLayer/Main_Menu

var room:Spatial
var roompath = "res://Rooms/%s.tscn"
var world:Spatial

var Nickname_doc:Dictionary
var User_doc:Dictionary

func _ready():
	get_tree().set_auto_accept_quit(false)
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	Collections.connect("got_nickname",self,"_update_nickname")

func logged_in(auth):
	#set email for finding user
	email = auth["email"]
	Collections.list("Users")
	var existing_users = yield(Collections,"got_list")
	if existing_users.has(email): #load and set user
		Collections.get_user(email)
		User_doc = yield(Collections,"got_user")
		player_info.set_level_progress(User_doc["Experience"],true)
		Collections.get_nickname(email)
		update_status("Online")
	else:		#create user nad nickname then update nickname
		Collections.add_user(email)
		User_doc = yield(Collections,"got_user")
		Collections.add_nickname(email,"")
		Nickname_doc = yield(Collections,"got_nickname")
		player_info.Username_dialog.popup()
		var new_name = yield(player_info.Username_dialog,"new_username")
		Collections.update_nickname(email,new_name)
	player_info.show()

func _update_nickname(doc):
	if doc["Email"] == email:
		Nickname_doc = doc
		player_info.set_name_number(Nickname_doc["Name"],Nickname_doc["Number"])
	if peer != null:
		for user in User_info_array:
			if user[1]["Email"] == doc["Email"]:
				user[1]["Name"] = doc["Name"]
		rpc("_update_user_info",User_info_array)

func host_joined():
	current_menu.queue_free()
	roompath %= game_dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(load("res://Rooms/Room.gd"))

func update_status(new_status):
	User_doc["Status"] = new_status
	Collections.update_user(email,User_doc)
	User_doc = yield(Collections,"got_user")
	emit_signal("status_updated")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		update_status("offline")
		yield(self,"status_updated")
		if peer != null:
			if get_tree().is_network_server():
				Collections.delete_game(game_dict["Name"])
				yield(Collections,"list_updated")
		get_tree().quit()

##### Netowrking Stuff #####
signal update_gui

var seatcount:int = 0
var peer:NetworkedMultiplayerENet

var own_id = 1

var game_dict:Dictionary
var current_players:int = 0

sync var User_info_array = [] setget _set_user_info
sync var host_info setget _set_host

func start_host(dict:Dictionary):
	game_dict = dict.duplicate()
	host_info = [own_id,Nickname_doc,User_doc]
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(dict["PORT"], dict["Max_players"])
	get_tree().network_peer = peer
	Error = peer.connect("peer_connected",self,"player_connected")
	Error = peer.connect("peer_disconnected",self,"player_disconnected")
	host_joined()
	set_network_master(1)
	update_status("hosting")
	yield(self,"status_updated")
	if Error:
		print(Error)

func join_game(dict:Dictionary): #get signal from serverlist
	var Error
	game_dict = dict.duplicate()
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_client(dict["IP"],dict["PORT"])
	get_tree().network_peer = peer
	Error = peer.connect("connection_succeeded",self,"connected")
	Error = peer.connect("connection_failed",self,"failed")
	Error = peer.connect("server_disconnected",self,"kicked")
	yield(peer,"connection_succeeded")
	update_status("in-game")
	yield(self,"status_updated")
	host_joined()
	if Error:
		print(Error)
	
func player_connected(id):
	current_players += 1
	if current_players >= seatcount:
		peer.refuse_new_connections = false
	rset_id(id,"host_info",host_info)
	
func player_disconnected(id):
	current_players -= 1
	if current_players < seatcount:
		peer.refuse_new_connections = false
	room.rpc("_player_left",id)
	for User in User_info_array:
		if id == User[0]:
			User_info_array.remove(User_info_array.find(User))
			rset("User_info_array",User_info_array)
	upadte_game()

func connected():
	print("con")
	set_network_master(1)
	own_id = get_tree().get_network_unique_id()
	rpc_id(1,"new_user_info",own_id,Nickname_doc,User_doc)
	
func failed():
	print("Error")
	
func kicked(): #Server disconected clos connection, unload game, load menu
	print("got kicked")
	User_info_array = []
	host_info = null
	stop()
	room.queue_free()
	var menu = preload("res://Menu_UI/Main_Menu.tscn").instance()
	add_child(menu)
	update_status("online")
	yield(self,"status_updated")

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

func logout():
	player_info.hide()

func _add_firend(friend_email):
	var User_to_add
	Collections.get_user(email)
	User_to_add = yield(Collections,"got_user")
	User_to_add["Requestby"].append(friend_email)
	Collections.update_user(friend_email,User_to_add)
	User_to_add = yield(Collections,"got_user")
	User_doc["Requested"].append(friend_email)
	Collections.update_user(email,User_doc)
	User_doc = yield(Collections,"got_user")


func _delcine_request(friend_email):
	Collections.get_user(friend_email)
	var usr = yield(Collections,"got_user")
	var usr_doc = usr
	if usr_doc["Requested"].has(email):
		usr_doc["Requested"].remove(usr_doc["Requested"].find(email))
		usr_doc["Blockedby"].append(email)
		Collections.update_user(friend_email,usr_doc)
		yield(Collections,"got_user")
	if User_doc["Requestby"].has(friend_email):
		User_doc["Requestby"].remove(User_doc["Requestby"].find(friend_email))
		User_doc["Blocked"].append(friend_email)
		Collections.update_user(email,User_doc)
		yield(Collections,"got_user")

func _accept_request(friend_email):
	Collections.get_user(friend_email)
	var usr = yield(Collections,"got_user")
	var usr_doc = usr
	if usr_doc["Requested"].has(email):
		usr_doc["Requested"].remove(usr_doc["Requested"].find(email))
		usr_doc["Friends"].append(email)
		Collections.update_user(friend_email,usr_doc)
		yield(Collections,"got_user")
	if User_doc["Requestby"].has(friend_email):
		User_doc["Requestby"].remove(User_doc["Requestby"].find(friend_email))
		User_doc["Friends"].append(friend_email)
		Collections.update_user(email,User_doc)
		yield(Collections,"got_user")
