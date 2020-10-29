extends Control

signal host_game(Game)
signal join_game(Game)
signal got_game(game)

onready var Open_Games:FirestoreCollection = Firebase.Firestore.collection("OpenGames")
var IPaddress
onready var game_doc:=FirestoreDocument.new()
onready var host_game_dialog = $Host_game_dialog
onready var join_game_doalog = $Join_game_dialog
onready var join_b:Button = $VBC/Join
onready var host_b:Button = $VBC/Host
var parent

signal open_games_listed(list)

func _on_Host_pressed():
	host_game_dialog.popup()

func _on_Join_pressed():
	join_game_doalog.popup()
	Collections.update_games()
	parent.Game_list = yield(Collections,"list_updated")
	join_game_doalog.list_servers(parent.Game_list.keys())
	


func _on_Play_offline_pressed():
	pass
