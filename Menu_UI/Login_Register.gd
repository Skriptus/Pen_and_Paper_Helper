extends Control

onready var email:LineEdit = $Panel/Labels/Emailbox/Email
onready var password:LineEdit = $Panel/Labels/Passwordbox/Password

onready var login:Button = $Panel/Labels/Buttons/Login
onready var register:Button = $Panel/Labels/Buttons/Register

onready var rememberme_b:Button = $Panel/Labels/Remember/Rememberme
onready var autologin_b:Button = $Panel/Labels/Remember/Autologin

var rememberme:bool
var autologin:bool
var save_load

var settings:Dictionary

func _ready():
	### connect firebase functions ###
	Firebase.Auth.connect("login_failed",self,"login_failed")

func _on_Login_pressed():
	if !email.text:
		$Panel/Labels/Notification.text = "NO EMAIL"
	elif !password.text:
		$Panel/Labels/Notification.text = "NO PASSWORD"
	else:
		Firebase.Auth.login_with_email_and_password(email.text,password.text)
		save_load.save_login_settings(get_settings())

func _on_Register_pressed():
	if !email.text:
		$Panel/Labels/Notification.text = "NO EMAIL"
	elif !password.text:
		$Panel/Labels/Notification.text = "NO PASSWORD"
	else:
		Firebase.Auth.signup_with_email_and_password(email.text,password.text)
		save_load.save_login_settings(get_settings())

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
	get_parent()._login_aborted()
