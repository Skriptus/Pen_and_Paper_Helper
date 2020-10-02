extends Panel

onready var join = $HBoxContainer/Join
onready var server_name = $HBoxContainer/Servername
onready var players = $HBoxContainer/Players

var Server_dict

signal join_server(Server_dict)

func _on_Join_pressed():
	emit_signal("join_server",Server_dict)

func fill(dict):
	Server_dict = dict
	server_name.text = dict["Name"]
	players.text = String(dict["current_players"]) + "/" + String(dict["Max_players"])
	
