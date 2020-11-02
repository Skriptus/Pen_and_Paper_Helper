extends Node

signal got_game(game)
signal got_user(user)
signal got_list(elements)
signal list_updated(updated_list)

var base_url = "https://firestore.googleapis.com/v1/"
var extended_url = "projects/pen-and-paper-helper/databases/(default)/documents/"

var OpenGames:FirestoreCollection
var Users:FirestoreCollection

var OpenGames_list:Dictionary
var Users_list:Dictionary

var working_allowed = false


func _ready():
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	OpenGames = Firebase.Firestore.collection("OpenGames")
	Users = Firebase.Firestore.collection("Users")

func logged_in(auth):
	Firebase.Firestore.auth = auth
	OpenGames.auth = auth
	Users.auth = auth
	working_allowed = true

func generate_number(nickname):
	var number = 0
	var used_numbers = [0]
	for key in Users_list.keys():
		if Users_list[key]["Name"] == nickname:
			used_numbers.append(Users_list[key]["Number"])
	var rng = RandomNumberGenerator.new()
	while used_numbers.has(number):
		rng.randomize()
		number = rng.randi_range(0,9999)
	return number

func list(listname):
	var list:Array =[]
	Firebase.Firestore.list(listname)
	var docs = yield(Firebase.Firestore,"listed_documents")
	for doc in docs["documents"]:
		list.append(doc["name"].rsplit("/",true,1)[1])
	emit_signal("got_list",list)

func update_users():
	if working_allowed == true:
		working_allowed = false
		Users_list.clear()
		list("Users")
		var list_array = yield(self,"got_list")
		for item in list_array:
			get_user(item)
			var item_doc = yield(self,"got_user")
			Users_list[item] = item_doc
		working_allowed = true
		emit_signal("list_updated",Users_list)


func update_games():
	if working_allowed == true:
		working_allowed = false
		OpenGames_list.clear()
		list("OpenGames")
		var list_array = yield(self,"got_list")
		for item in list_array:
			get_game(item)
			var item_doc = yield(self,"got_game")
			OpenGames_list[item] = item_doc
		working_allowed = true
		emit_signal("list_updated",OpenGames_list)


func get_user(email):
	var User_doc := FirestoreDocument.new()
	Users.get(email)
	User_doc = yield(Users,"get_document")
	User_doc.fields2dict(User_doc)
	emit_signal("got_user",User_doc.doc_fields)

func add_user(email:String):
	var User_doc_default:Dictionary = {
	"Name": "",
	"Email": email,
	"Number": 0,
	"Friends": [],
	"Blocked": [],
	"Requested": [],
	"Experience": 0
	}
	var User_doc := FirestoreDocument.new({},email,User_doc_default)
	Users.add(email,User_doc.dict2fields(User_doc_default))
	User_doc = yield(Users,"add_document")
	User_doc.fields2dict(User_doc)
	emit_signal("got_user",User_doc.doc_fields)
	update_users()
	
func update_user(email:String,fieldsdict:Dictionary):
	var User_doc := FirestoreDocument.new()
	Users.update(email,User_doc.dict2fields(fieldsdict))
	User_doc = yield(Users,"update_document")
	User_doc.fields2dict(User_doc)
	emit_signal("got_user",User_doc.doc_fields)
	update_users()
	
func delete_user(email):
	Users.delete(email)
	yield(Users,"delete_document")
	update_users()

func get_game(gamename):
	var Game_doc := FirestoreDocument.new()
	OpenGames.get(gamename)
	Game_doc = yield(OpenGames,"get_document")
	Game_doc.fields2dict(Game_doc)
	emit_signal("got_game",Game_doc.doc_fields)

func add_game(game_dict):
	var Game_doc := FirestoreDocument.new(game_dict,game_dict["Host"],game_dict)
	OpenGames.add(game_dict["Host"],Game_doc.dict2fields(game_dict))
	Game_doc = yield(OpenGames,"add_document")
	Game_doc.fields2dict(Game_doc)
	emit_signal("got_game",Game_doc.doc_fields)
	update_games()
	
func update_game(game_name:String,fieldsdict:Dictionary):
	var Game_doc := FirestoreDocument.new()
	OpenGames.update(game_name,Game_doc.dict2fields(fieldsdict))
	Game_doc = yield(OpenGames,"update_document")
	Game_doc.fields2dict(Game_doc)
	update_games()
	emit_signal("got_game",Game_doc.doc_fields)
	
func delete_game(game_name):
	OpenGames.delete(game_name)
	yield(OpenGames,"delete_document")
	update_games()
