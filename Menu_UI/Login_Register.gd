extends Control

onready var email:LineEdit = $Panel/Labels/Emailbox/Email
onready var password:LineEdit = $Panel/Labels/Passwordbox/Password

var login:Button
var register:Button

var rememberme_b:Button
var autologin_b:Button

var mainmenu:Node
var loginsettings:Object

var rememberme:bool
var autologin:bool

var settings:Dictionary

func login_register():
	### connect firebase functions ###
	Firebase.Auth.connect("login_failed",self,"login_failed")
		
	login = $Panel/Labels/Buttons/Login
	register = $Panel/Labels/Buttons/Register
	
	rememberme_b = $Panel/Labels/Remember/Rememberme
	autologin_b = $Panel/Labels/Remember/Autologin
	
	settings = loginsettings.load_settings()
	if settings["RememberMe"]:
		rememberme_b.pressed = true
		rememberme = true
		email.text = settings["Email"]
		password.text = settings["Password"]
	if settings["Autologin"]:
		autologin_b.pressed = true
		autologin = true
		_on_Login_pressed()

func _on_Login_pressed():
	if !email.text:
		$Panel/Labels/Notification.text = "NO EMAIL"
	elif !password.text:
		$Panel/Labels/Notification.text = "NO PASSWORD"
	else:
		Firebase.Auth.login_with_email_and_password(email.text,password.text)

func _on_Register_pressed():
	if !email.text:
		$Panel/Labels/Notification.text = "NO EMAIL"
	elif !password.text:
		$Panel/Labels/Notification.text = "NO PASSWORD"
	else:
		Firebase.Auth.signup_with_email_and_password(email.text,password.text)


func _on_Rememberme_toggled(button_pressed):
	rememberme = button_pressed
	if !button_pressed: # 
		autologin = false
		autologin_b.pressed = false


func _on_Autologin_toggled(button_pressed):
	autologin = button_pressed
	rememberme = true
	rememberme_b.pressed = true
	
func login_failed(code,massage):
	$Panel/Labels/Notification.text = massage +" "+String(code)
	
	
func get_settings() -> Dictionary: # recieve settings on successful login
	settings["RememberMe"] = rememberme
	settings["Autologin"] = autologin
	settings["Email"] = email.text
	settings["Password"] = password.text
	return settings

func _on_X_pressed():
	email.clear()
	password.clear()
	mainmenu._login_aborted()
