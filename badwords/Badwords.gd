tool
extends Node

var badwords = []
var languages = ["english","german","french","spanish"]

func _ready():
	for language in languages:
		var path = "res://badwords/%s.res"
		path %= language
		var file = File.new()
		file.open(path,file.READ)
		while !file.eof_reached():
			badwords.append(file.get_line ())
		file.close()


func _check_word(new_text:String) -> bool:
	for word in badwords:
		if word in new_text:
			return false
	return true
