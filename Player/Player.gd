extends Node

class_name player

var game_character:Object

onready var network:Node = $Network
onready var save_load:Node = $Save_Load
onready var mainmenu:Node = $Main_Menu

var Firestore_Users:Object
var email:String
var User_doc_default:Dictionary = {
	"Username": "",
	"Usernumber": 0,
	"Friends": [],
	"Blocked": []
	}
var user_doc: FirestoreDocument

func _ready():
	network.parent = self
	save_load.parent = self
	mainmenu.parent = self
	Firebase.Auth.connect("login_succeeded", self,"logged_in")


func logged_in(auth):
	email = auth["email"]
	Firestore_Users = Firebase.Firestore.collection("Users")
	get_node("Main_Menu").username.Firestore_Users = Firestore_Users
	Firebase.Firestore.auth = auth
	Firebase.Firestore.list("Users")
	var docs = yield(Firebase.Firestore,"listed_documents")
	var doc_exists = false
	for doc in docs["documents"]:
		var docname = doc["name"].rsplit("/",true,1)[1]
		if docname == email:
			doc_exists = true
			Firestore_Users.get(docname)
			user_doc = yield(Firestore_Users,"get_document")
			var dict = user_doc.fields2dict(user_doc)
			if !dict["Username"]:
				mainmenu.username.show()
	if !doc_exists:
		user_doc = FirestoreDocument.new()
		Firestore_Users.add(email,user_doc.dict2fields(User_doc_default))
	get_node("Main_Menu").user_doc = user_doc
