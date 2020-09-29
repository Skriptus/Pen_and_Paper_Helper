extends Control

func set_name_number(Name:String,Number:String):
	$HBoxContainer/VBoxContainer/HBoxContainer/Name.text = Name + " #" + Number

func set_level_progress(experience:String):
	var Level = floor(float(experience)/50)
	var progress = (float(experience)/50)-Level
	var Leveltext = "I"
	$HBoxContainer/VBoxContainer/HBoxContainer/Level.text = String(Leveltext)
	$HBoxContainer/VBoxContainer/Levelprogress.value = progress
