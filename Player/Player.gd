extends Node

class_name player

var game_character:Object
var IPAddress:String
var email:String
var login_auth

onready var save_load:Node = $Save_Load
onready var mainmenu:Node = $Main_Menu
onready var player_info:Node = $Player_Info

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
	else:		#create user nad nickname then update nickname
		Collections.add_user(email)
		User_doc = yield(Collections,"got_user")
		Collections.add_nickname(email,"")
		Nickname_doc = yield(Collections,"got_nickname")
		player_info.Username_dialog.popup()
		var new_name = yield(player_info.Username_dialog,"new_username")
		Collections.update_nickname(email,new_name)
		yield(Collections,"got_nickname")
	Nickname_doc = yield(Collections,"got_nickname")
	player_info.set_name_number(Nickname_doc.doc_fields["Name"],Nickname_doc.doc_fields["Number"])
	
	
func hosting():
	mainmenu.queue_free()
	roompath %= Network.game_dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(preload("res://Rooms/Room.gd"))

func joined():
	mainmenu.queue_free()
	roompath %= Network.game_dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)
	room.set_script(preload("res://Rooms/Room.gd"))

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if get_tree().is_network_server():
			Collections.delete_game(Network.game_dict["Name"])
			yield(Collections,"list_updated")
		get_tree().quit()
		
