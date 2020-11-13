extends Node

signal status_updated
signal update_gui

var email:String

var User_list:Dictionary
var Game_list:Dictionary

onready var player_info = $CanvasLayer/Player_Info
onready var mu_UI = $CanvasLayer/MultiplayerUI
onready var save_load = $Save_Load
##### Netowrking Stuff #####

var seatcount:int = 0
var peer:NetworkedMultiplayerENet

var own_id = 1

var current_players:int = 0

#### Login #####
onready var loginbutton = $CanvasLayer/Login_Logout
onready var login_register = $CanvasLayer/Login_Register

var room:Spatial
var roompath = "res://Rooms/%s.tscn"
var world:Spatial


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
		User_list[email] = yield(Collections,"got_user")
		player_info.Username_dialog.popup()
		var new_name = yield(player_info.Username_dialog,"new_username")
		User_list[email]["Name"] = new_name
		User_list[email]["Number"] = Collections.generate_number(new_name)
		Collections.update_user(email,new_name)
		User_list[email] = yield(Collections,"got_user")
	player_info.fill(User_list[email])
	update_status("ONLINE")
	login_register.hide()
	loginbutton.text = "LOGOUT"
	player_info.show()
	mu_UI.host_b.disabled = false
	mu_UI.join_b.disabled = false

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

func host_joined():
	roompath %= String(Game_list[email]["Room"])
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(load("res://Rooms/Room.gd"))
	login_register.hide()
	mu_UI.hide()

func update_status(new_status):
	User_list[email]["Status"] = new_status
	Collections.update_user(email,User_list[email])
	User_list[email] = yield(Collections,"got_user")
	emit_signal("status_updated")

func start_host(dict:Dictionary):
	dict["Host"] = email
	Collections.add_game(dict)
	Game_list[email] = yield(Collections,"got_game")
	host_joined()
	peer = NetworkedMultiplayerENet.new()
	var Error = peer.create_server(Game_list[email]["PORT"], Game_list[email]["Max_players"])
	get_tree().network_peer = peer
	Error = peer.connect("peer_connected",self,"player_connected")
	Error = peer.connect("peer_disconnected",self,"player_disconnected")
	set_network_master(1)
	update_status("HOSTING")
	yield(self,"status_updated")
	room.Players_dict[own_id] = [own_id,"PosHost",User_list[email]]
	room.add_actor("PosHost",own_id)
	if Error:
		print(Error)

func join_game(dict:Dictionary): #get signal from serverlist
	Game_list[email] = dict
	host_joined()
	peer = NetworkedMultiplayerENet.new()
	var Error = peer.create_client(dict["IP"],dict["PORT"])
	get_tree().network_peer = peer
	Error = peer.connect("connection_succeeded",self,"connected")
	Error = peer.connect("connection_failed",self,"failed")
	Error = peer.connect("server_disconnected",self,"kicked")
	yield(peer,"connection_succeeded")
	update_status("INGAME")
	yield(self,"status_updated")
	if Error:
		print(Error)
	
func player_connected(id):
	current_players += 1
	if current_players >= seatcount:
		peer.refuse_new_connections = false
	
func player_disconnected(id):
	current_players -= 1
	if current_players < seatcount:
		peer.refuse_new_connections = false
	room.remove_player(id)
	room.Players_dict.erase(id)
	room.rpc("set_Players_dict",room.Players_dict)
	update_game()

func connected():
	set_network_master(1)
	own_id = get_tree().get_network_unique_id()
	rpc_id(1,"new_user_info",own_id,email)
	
func failed():
	print("Error")
	
func kicked(): #Server disconected clos connection, unload game, load menu
	User_list[email].erase("id")
	print("got kicked")
	stop()
	room.queue_free()
	update_status("ONLINE")
	yield(self,"status_updated")

func stop(): # close connection if existend
	if peer != null:
		peer.close_connection()
		peer = null	

func update_game():
	Game_list[email]["current_players"] = current_players
	Collections.update_game(Game_list[email])
	Game_list[email] = yield(Collections,"got_game")
	print(Game_list[email])

master func new_user_info(id,mail):
	User_list[mail]["id"] = id
	var pos = room.get_pos(Game_list[email]["Max_players"])
	room.Players_dict[id] = [id,pos,User_list[mail]]
	room.add_actor(pos,id)
	room.rpc("set_Players_dict",room.Players_dict)
	update_game()
#### login_logoutstuff ####

func logout():
	loginbutton.text = "LOGIN/REGISTER"
	player_info.hide()

func _add_firend(friend_email):
	Collections.get_user(friend_email)
	User_list[friend_email] = yield(Collections,"got_user")
	User_list[friend_email]["Requestby"].append(email)
	Collections.update_user(friend_email,User_list[friend_email])
	User_list[email]["Requested"].append(friend_email)
	Collections.update_user(email,User_list[email])
	User_list[email] = yield(Collections,"got_user")

func _delcine_request(friend_email):
	Collections.get_user(friend_email)
	User_list[friend_email] = yield(Collections,"got_user")
	Collections.get_user(email)
	User_list[email] = yield(Collections,"got_user")
	if User_list[friend_email]["Requested"].has(email):
		User_list[friend_email]["Requested"].remove(User_list[friend_email]["Requested"].find(email))
		User_list[email]["Blockedby"].append(email)
		Collections.update_user(friend_email,User_list[friend_email])
		User_list[friend_email] = yield(Collections,"got_user")
	if User_list[email]["Requestby"].has(friend_email):
		User_list[email]["Requestby"].remove(User_list[email]["Requestby"].find(friend_email))
		User_list[email]["Blocked"].append(friend_email)
		Collections.update_user(email,User_list[email])
		User_list[email] = yield(Collections,"got_user")

func _accept_request(friend_email):
	Collections.get_user(friend_email)
	User_list[friend_email] = yield(Collections,"got_user")
	if User_list[friend_email]["Requested"].has(email):
		User_list[friend_email]["Requested"].remove(User_list[friend_email]["Requested"].find(email))
		User_list[friend_email]["Friends"].append(email)
		Collections.update_user(friend_email,User_list[friend_email])
		User_list[friend_email] = yield(Collections,"got_user")
	if User_list[email]["Requestby"].has(friend_email):
		User_list[email]["Requestby"].remove(User_list[email]["Requestby"].find(friend_email))
		User_list[email]["Friends"].append(friend_email)
		Collections.update_user(email,User_list[email])
		User_list[email] = yield(Collections,"got_user")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if email:
			update_status("OFFLINE")
			yield(self,"status_updated")
			if peer != null:
				if get_tree().is_network_server():
					Collections.delete_game(email)
		get_tree().quit()
