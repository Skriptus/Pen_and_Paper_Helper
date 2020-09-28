extends Control

onready var loginbutton = $Login
onready var login_register = $Login_Register
onready var username = $Username

var parent:Object

func _ready():
	### connect Firebase functions ###
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	
	### connect UI Functions ###
	login_register.mainmenu = self
	login_register.loginsettings = $save_load_loginsettings
	login_register.login_register()
	
	
func logged_in(auth):
	$save_load_loginsettings.save_settings(login_register.get_settings())
	login_register.hide()
	loginbutton.hide()
	print("logged in as: ",auth["email"])
	$Main_UI.show()
	

func _on_Login_pressed():
	loginbutton.hide()
	login_register.show()

func _login_aborted():
	loginbutton.show()
	login_register.hide()
