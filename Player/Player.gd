extends Node

class_name player

signal status_updated

var game_character:Object
var IPAddress:String
var email:String
var login_auth

onready var save_load:Node = $Save_Load
onready var mainmenu:Node = $Main_Menu
onready var player_info:Node = $Main_Menu/Player_Info

var room
var roompath = "res://Rooms/%s.tscn"
var world

var Nickname_doc:FirestoreDocument
var User_doc:FirestoreDocument

func _ready():
	get_tree().set_auto_accept_quit(false)
	Network.parent = self
	save_load.parent = self
	player_info.parent = self
	mainmenu.muliplayer_UI.parent = self
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	Collections.connect("got_nickname",self,"_update_nickname")

func logged_in(auth):
	#set email for finding user
	login_auth = auth
	email = auth["email"]
	Collections.list("Users")
	var existing_users = yield(Collections,"got_list")
	#yield(get_tree().create_timer(1.0), "timeout")
	if existing_users.has(email): #load and set user
		Collections.get_user(email)
		User_doc = yield(Collections,"got_user")
		player_info.set_level_progress(User_doc.doc_fields["Experience"],true)
		Collections.get_nickname(email)
		update_status("online")
	else:		#create user nad nickname then update nickname
		Collections.add_user(email)
		User_doc = yield(Collections,"got_user")
		Collections.add_nickname(email,"")
		Nickname_doc = yield(Collections,"got_nickname")
		player_info.Username_dialog.popup()
		var new_name = yield(player_info.Username_dialog,"new_username")
		Collections.update_nickname(email,new_name)

func _update_nickname(doc):
	if doc.doc_fields["Email"] == email:
		Nickname_doc = doc
		player_info.set_name_number(Nickname_doc.doc_fields["Name"],Nickname_doc.doc_fields["Number"])
	if Network.peer != null:
		for user in Network.User_info_array:
			if user[1]["Email"] == doc.doc_fields["Email"]:
				user[1]["Name"] = doc.doc_fields["Name"]
		Network.rpc("_update_user_info",Network.User_info_array)

func host_joined():
	mainmenu.queue_free()
	roompath %= Network.game_dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(load("res://Rooms/Room.gd"))

func update_status(new_status):
	User_doc.doc_fields["Status"] = new_status
	Collections.update_user(email,User_doc.doc_fields)
	User_doc = yield(Collections,"got_user")
	User_doc.fields2dict(User_doc)
	emit_signal("status_updated")

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		update_status("offline")
		yield(self,"status_updated")
		if get_tree().is_network_server():
			Collections.delete_game(Network.game_dict["Name"])
			yield(Collections,"list_updated")
		get_tree().quit()
		
