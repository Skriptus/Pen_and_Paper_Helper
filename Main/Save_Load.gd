extends Node

var parent:Object

var email:String
var password:String

var savegamedir:Directory

var savedict:Dictionary = {
	"Email": email,
	"Password": password,
	"RememberMe": false,
	"Autologin": false
}

func _ready():
	savegamedir = Directory.new()
	var direxits = savegamedir.dir_exists("user://settings/")
	if !direxits:
		var err = savegamedir.make_dir("user://settings/")
		if err:
			print(err)
	

func load_login_settings() -> Dictionary:
	var f = File.new()
	var fileexsits = f.file_exists("user://settings/login.bin")
	if !fileexsits:
		var err = f.open_encrypted_with_pass("user://settings/login.bin", File.WRITE, OS.get_unique_id())
		f.store_var(savedict)
		f.close()
		if err:
			print(err)
	var err = f.open_encrypted_with_pass("user://settings/login.bin", File.READ, OS.get_unique_id())
	var savedict = f.get_var()
	f.close()
	if err:
		print(err,savedict)
	return savedict

func save_login_settings(dict):
	var f = File.new()
	var err = f.open_encrypted_with_pass("user://settings/login.bin", File.WRITE, OS.get_unique_id())
	f.store_var(dict)
	f.close()
	if err:
		print(err)
