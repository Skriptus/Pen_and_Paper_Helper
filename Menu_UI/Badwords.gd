tool
extends "res://Menu_UI/Username.gd"

var badwords = []
var languages = ["english","german","french","spanish"]

func _ready():
	for language in languages:
		var path = "res://Menu_UI/Username/badwords/%s.txt"
		path %= language
		var file = File.new()
		file.open(path,file.READ)
		while !file.eof_reached():
			badwords.append(file.get_line ())
		file.close()


func _on_Username_text_changed(new_text):
	if badwords.has(new_text):
		allow_name = false
	else:
		allow_name = true
