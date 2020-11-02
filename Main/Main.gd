extends Node

signal status_updated

var game_character:Object
var IPAddress:String
var email:String

var User_list:Dictionary
var Game_list:Dictionary

onready var player_info = $CanvasLayer/Player_Info
onready var mu_UI = $CanvasLayer/MultiplayerUI
onready var save_load = $Save_Load
var connected_users:Array = []
var host_info:Dictionary
##### Netowrking Stuff #####
signal update_gui

var seatcount:int = 0
var peer:NetworkedMultiplayerENet

var own_id = 1

var game_dict:Dictionary
var current_players:int = 0

#### Login #####
onready var loginbutton = $CanvasLayer/Login_Logout
onready var login_register = $CanvasLayer/Login_Register

var room:Spatial
var roompath = "res://Rooms/%s.tscn"
var world:Spatial

var Nickname_doc:Dictionary
var User_doc:Dictionary

func _ready():
	get_tree().set_auto_accept_quit(false)
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	player_info.parent = self
	player_info.Friendlist.parent = self
	mu_UI.parent = self
	login_register.save_load = save_load
	var savedict = save_load.load_login_settings()
	if savedict["RememberMe"]:
		login_register.email.text = save_load.savedict["Email"]
		login_register.password.text = save_load.savedict["Password"]
		login_register.rememberme_b.pressed = true
		if savedict["Autologin"]:
			Firebase.Auth.login_with_email_and_password(savedict["Email"],savedict["Password"])
			login_register.autologin_b.pressed = true
			
func logged_in(auth):
	Collections.update_users()
	User_list = yield(Collections,"list_updated")
	Collections.update_games()
	Game_list = yield(Collections,"list_updated")
	#set email for finding user
	email = auth["email"]
	if not User_list.keys().has(email): #load and set user
		Collections.add_user(email)
		User_list = yield(Collections,"list_updated")
		player_info.Username_dialog.popup()
		var new_name = yield(player_info.Username_dialog,"new_username")
		User_list[email]["Name"] = new_name
		User_list[email]["Number"] = Collections.generate_number(new_name)
		Collections.update_user(email,new_name)
		User_list = yield(Collections,"list_updated")
	User_doc = User_list[email]
	player_info.set_level_progress(User_doc["Experience"],true)
	player_info.set_name_number(User_doc["Name"],User_doc["Number"])
	update_status("Online")
	login_register.hide()
	loginbutton.text = "LOGOUT"
	player_info.show()
	mu_UI.host_b.disabled = false
	mu_UI.join_b.disabled = false

func host_joined():
	roompath %= String(game_dict["Room"])
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(load("res://Rooms/Room.gd"))
	login_register.hide()
	mu_UI.hide()

func update_status(new_status):
	User_doc["Status"] = new_status
	Collections.update_user(email,User_doc)
	User_doc = yield(Collections,"got_user")
	emit_signal("status_updated")

func start_host(dict:Dictionary):
	dict["Host"] = email
	Collections.add_game(dict)
	var game = yield(Collections,"got_game")
	game_dict = game
	host_joined()
	var Error
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_server(game_dict["PORT"], game_dict["Max_players"])
	get_tree().network_peer = peer
	Error = peer.connect("peer_connected",self,"player_connected")
	Error = peer.connect("peer_disconnected",self,"player_disconnected")
	_set_host_info(User_list[game_dict["Host"]])
	set_network_master(1)
	update_status("hosting")
	yield(self,"status_updated")
	if Error:
		print(Error)

func join_game(dict:Dictionary): #get signal from serverlist
	var Error
	game_dict = dict.duplicate()
	host_joined()
	peer = NetworkedMultiplayerENet.new()
	Error = peer.create_client(dict["IP"],dict["PORT"])
	get_tree().network_peer = peer
	Error = peer.connect("connection_succeeded",self,"connected")
	Error = peer.connect("connection_failed",self,"failed")
	Error = peer.connect("server_disconnected",self,"kicked")
	yield(peer,"connection_succeeded")
	update_status("in-game")
	yield(self,"status_updated")
	if Error:
		print(Error)
	
func player_connected(id):
	current_players += 1
	if current_players >= seatcount:
		peer.refuse_new_connections = false
	
func player_disconnected(id):
	for usr in connected_users:
		if id == usr["id"]:
			connected_users.remove(connected_users.find(usr))
	rset("connected_users",connected_users)
	current_players -= 1
	if current_players < seatcount:
		peer.refuse_new_connections = false
	upadte_game()

func connected():
	set_network_master(1)
	own_id = get_tree().get_network_unique_id()
	User_doc["id"] = own_id
	rpc_id(1,"new_user_info",own_id,email)
	
func failed():
	print("Error")
	
func kicked(): #Server disconected clos connection, unload game, load menu
	User_doc.erase("id")
	print("got kicked")
	stop()
	room.queue_free()
	update_status("online")
	yield(self,"status_updated")

func stop(): # close connection if existend
	if peer != null:
		peer.close_connection()
		peer = null	

func upadte_game():
	game_dict["current_players"] = current_players
	Collections.update_game(game_dict["Name"],game_dict)
	game_dict = yield(Collections,"got_game")

master func new_user_info(id,mail):
	Collections.update_users()
	User_list = yield(Collections,"list_updated")
	User_list[mail]["id"] = id
	var new_users = connected_users.duplicate()
	new_users.append(User_list[mail])
	rpc("_set_host_info",host_info)
	rpc("_set_con_users",new_users)
	
	
sync func _set_con_users(new_usr_array):
	for Usr in connected_users:
		if new_usr_array.has(Usr):
			continue
		else:
			room.remove_player(Usr)
	for Usr in new_usr_array:
		if connected_users.has(Usr):
			continue
		else:
			room.add_player(Usr)
	connected_users = new_usr_array
	if room.Lobby:
		room.Lobby.update()

sync func _set_host_info(new_host_info):
	if not room.host:
		room.add_host()
	room.update_host(new_host_info)
	host_info = new_host_info
	if room.Lobby:
		room.Lobby.update()

#### login_logoutstuff ####

func logout():
	loginbutton.text = "LOGIN/REGISTER"
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

func _login_aborted(): 
	login_register.hide()

func _on_Login_Logout_pressed():
	if loginbutton.text == "LOGIN/REGISTER":
		loginbutton.text = "LOGOUT"
		login_register.show()
	else:
		save_load.savedict["Autologin"] = false
		login_register.autologin_b.pressed = false
		save_load.save_settings(save_load.savedict)
		loginbutton.text = "LOGIN/REGISTER"
		logout()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if email:
			update_status("offline")
			yield(self,"status_updated")
			if peer != null:
				if get_tree().is_network_server():
					Collections.delete_game(email)
					yield(Collections,"list_updated")
		get_tree().quit()
