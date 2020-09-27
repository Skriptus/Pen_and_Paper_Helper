extends Node

const ENVIRONMENT_VARIABLES : String = "environment_variables/"
onready var Auth = HTTPRequest.new()
onready var Firestore = Node.new()
onready var Database = Node.new()

# Configuration used by all files in this project
# These values can be found in your Firebase Project
# See the README on Github for how to access
var config = {  
	"apiKey": "AIzaSyB-Uhu19tGim-2pFZpILIJMiuFN8uWO8VE",
	"authDomain": "pen-and-paper-helper.firebaseapp.com",
	"databaseURL": "https://pen-and-paper-helper.firebaseio.com",
	"projectId": "pen-and-paper-helper",
	"storageBucket": "pen-and-paper-helper.appspot.com",
	"messagingSenderId": "92719773961",
	"appId": "1:92719773961:web:f46afb19100294649dfbd8",
	"measurementId": "G-TTSH05GVR1",
	}

func load_config():
	if ProjectSettings.has_setting(ENVIRONMENT_VARIABLES+"apiKey"):
		for key in config.keys():
			config[key] = ProjectSettings.get_setting(ENVIRONMENT_VARIABLES+key)
	else:
		printerr("No configuration settings found, add them in override.cfg file.")

func _ready():
	load_config()
	Auth.set_script(preload("res://addons/GDFirebase/FirebaseAuth.gd"))
	Firestore.set_script(preload("res://addons/GDFirebase/FirebaseFirestore.gd"))
	Database.set_script(preload("res://addons/GDFirebase/FirebaseDatabase.gd"))
	Auth.set_config(config)
	Firestore.set_config(config)
	Database.set_config(config)
	add_child(Auth)
	add_child(Firestore)
	add_child(Database)
	Auth.connect("login_succeeded", Database, "_on_FirebaseAuth_login_succeeded")
	Auth.connect("login_succeeded", Firestore, "_on_FirebaseAuth_login_succeeded")
