extends Node

class_name player

signal got_user(doc)
signal list_updated
signal Nickname_updated(new_name,new_number)

var game_character:Object
var IPAddress:String
var email:String
var login_auth

onready var network:Node = $Network
onready var save_load:Node = $Save_Load
onready var mainmenu:Node = $Main_Menu
onready var player_info:Node = $Player_Info

var Nicknames:Dictionary
var Nicknames_collection:FirestoreCollection
var Nickname_doc:FirestoreDocument

var Nickname_doc_default:Dictionary = {
	"Name": "",
	"Number": 0,
	}

var Firestore_Users:FirestoreCollection
var user_doc: FirestoreDocument


var User_doc_default:Dictionary = {
	"Friends": [],
	"Blocked": [],
	"Experience": "300"
	}

var room
var roompath = "res://Rooms/%s.tscn"
var world

func _ready():
	network.parent = self
	save_load.parent = self
	player_info.parent = self
	mainmenu.muliplayer_UI.network = network
	mainmenu.muliplayer_UI.parent = self
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	network.connect("start_host",self,"hosting")

func logged_in(auth):
	#set email for finding user
	login_auth = auth
	email = auth["email"]
	Firestore_Users = Firebase.Firestore.collection("Users")
	Nicknames_collection = Firebase.Firestore.collection("Nicknames")
	Nicknames_collection.auth = auth
	Firebase.Firestore.auth = auth
	_upadate_Nickname_list()
	yield(self,"list_updated")
	_get_user(email)
	user_doc = yield(self,"got_user")


func _get_user(user_email):
	Firebase.Firestore.list("Users")
	var docs = yield(Firebase.Firestore,"listed_documents")
	var docname
	for doc in docs["documents"]:
		docname = doc["name"].rsplit("/",true,1)[1]
		if docname == user_email:
			Firestore_Users.get(docname)
			var new_user_doc = yield(Firestore_Users,"get_document")
			new_user_doc.fields2dict(new_user_doc)
			emit_signal("got_user",new_user_doc)
			return
	user_doc = FirestoreDocument.new({},user_email,User_doc_default)
	Firestore_Users.add(user_email,user_doc.dict2fields(User_doc_default))
	yield(Firestore_Users,"add_document")
	user_doc.fields2dict(user_doc)
	emit_signal("got_user",user_doc)

func _get_Nickname(search:String) -> Array:
	var result:Array
	for Nickname in Nicknames.keys():
		if Nickname.begins_with(search):
			result.append(Nicknames[Nickname])
			continue
		if Nicknames[Nickname]["Name"].begins_with(search):
			result.append(Nicknames[Nickname])
			continue
		if String(Nicknames[Nickname]["Number"]).begins_with(search):
			result.append(Nicknames[Nickname])
			continue
	return result

func _upadate_Nickname_list():
	Nicknames = {}
	Firebase.Firestore.list("Nicknames")
	var docs = yield(Firebase.Firestore,"listed_documents")
	for doc in docs["documents"]:
		var docname = doc["name"].rsplit("/",true,1)[1]
		Nicknames_collection.get(docname)
		var new_doc:FirestoreDocument = yield(Nicknames_collection,"get_document")
		new_doc.fields2dict(new_doc)
		Nicknames[new_doc.doc_name] = {"Name":new_doc.doc_fields["Name"],"Number":new_doc.doc_fields["Number"]}
	if !Nicknames.keys().has(email):
		var new_doc = FirestoreDocument.new()
		Nicknames_collection.add(email,new_doc.dict2fields(Nickname_doc_default))
	Nicknames_collection.get(email)
	Nickname_doc = yield(Nicknames_collection,"get_document")
	Nickname_doc.fields2dict(Nickname_doc)
	emit_signal("list_updated")

func _update_Nickname(new_name):
	var same_name_dict = _get_Nickname(new_name)
	var used_numbers:= [0]
	var rng = RandomNumberGenerator.new()
	var new_number = 0
	for used in same_name_dict:
		used_numbers.append(used["Number"])
	while used_numbers.has(new_number):
		rng.randomize()
		new_number = rng.randi_range(0,1000)
	Nickname_doc.doc_fields["Name"] = new_name
	Nickname_doc.doc_fields["Number"] = new_number
	Nicknames_collection.update(email,Nickname_doc.dict2fields(Nickname_doc.doc_fields))
	yield(Nicknames_collection,"update_document")
	_upadate_Nickname_list()
	emit_signal("Nickname_updated",new_name,new_number)

func hosting(dict):
	IPAddress = dict["IP"]
	mainmenu.queue_free()
	roompath %= dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)
	get_tree().set_auto_accept_quit(false)

func joined(dict):
	print(dict)
	mainmenu.queue_free()
	roompath %= dict["Room"]
	room = load(roompath).instance()
	self.add_child(room)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		var FC = Firebase.Firestore.collection("OpenGames")
		FC.auth = login_auth
		FC.delete(IPAddress)
		yield(FC,"delete_document")
		get_tree().quit()
		
