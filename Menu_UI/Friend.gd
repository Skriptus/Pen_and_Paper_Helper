extends Panel

onready var Name_label = $HBoxContainer/Name

func fill(Name:String,Status):
	Name_label.text = Name
