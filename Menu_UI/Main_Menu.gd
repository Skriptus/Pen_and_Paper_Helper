extends Control

onready var loginbutton = $MarginContainer/CenterContainer/Login
onready var login_register = $MarginContainer/CenterContainer/Login_Register
onready var save_load_settings = $save_load_loginsettings
onready var logout = $Logout
onready var muliplayer_UI = $MarginContainer/CenterContainer/Multiplayer_UI
onready var parent = get_parent()

func _ready():
	### connect Firebase functions ###
	Firebase.Auth.connect("login_succeeded", self,"logged_in")
	
	### connect UI Functions ###
	login_register.mainmenu = self
	login_register.loginsettings = save_load_settings
	login_register.login_register()
	yield(Collections,"got_user")
	muliplayer_UI.join_b.disabled = false
	muliplayer_UI.host_b.disabled = false
	
func logged_in(auth):
	save_load_settings.save_settings(login_register.get_settings())
	login_register.hide()
	loginbutton.hide()
	logout.show()
	muliplayer_UI.show()
	
func _on_Login_pressed():
	loginbutton.hide()
	login_register.show()

func _login_aborted():
	loginbutton.show()
	login_register.hide()

func _on_Logout_pressed():
	var login_settings = login_register.get_settings()
	login_settings["Autologin"] = false
	login_register.autologin_b.pressed = false
	save_load_settings.save_settings(login_settings)
	loginbutton.show()
	muliplayer_UI.hide()
	logout.hide()
