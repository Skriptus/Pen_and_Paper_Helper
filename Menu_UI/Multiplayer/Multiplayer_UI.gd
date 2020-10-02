extends Control

signal host_game()
signal got_game(game)

onready var Open_Games:FirestoreCollection = Firebase.Firestore.collection("OpenGames")
var IPaddress
onready var game_doc:=FirestoreDocument.new()
onready var host_game_dialog = $Host_game_dialog
onready var join_game_doalog = $Join_game_dialog
onready var join_b:Button = $VBC/Join
onready var host_b:Button = $VBC/Host
var network:Node
var parent

signal open_games_listed(list)

func _on_Host_pressed():
	host_game_dialog.popup()

func Host_game(Name:String,world:String,Max_Players:int = 4,Room:String = "DEFAULT"):
	game_doc.doc_fields = {
	"IP" : "127.0.0.1",
	"Max_players" : Max_Players,
	"Name" : Name,
	"PORT" : 4242,
	"current_players" : 0,
	"Room" : Room,
	"World" : world
	}
	var IPRequest = HTTPRequest.new()
	self.add_child(IPRequest)
	IPRequest.request("https://api.ipify.org")
	var result = yield(IPRequest,"request_completed")
	IPaddress = result[3].get_string_from_utf8()
	game_doc.doc_fields["IP"] = String(IPaddress)
	list_open_games()
	var open_games_list = yield(self,"open_games_listed")
	if open_games_list.has(IPaddress):
		Open_Games.delete(IPaddress)
		yield(Open_Games,"delete_document")
	game_doc.doc_name = IPaddress
	game_doc.doc_fields = game_doc.dict2fields(game_doc.doc_fields)
	Open_Games.add(IPaddress,game_doc.doc_fields)
	game_doc = yield(Open_Games,"add_document")
	game_doc.fields2dict(game_doc)
	network.emit_signal("start_host",game_doc.doc_fields)

func _on_Join_pressed():
	join_game_doalog.popup()
	list_open_games()
	var rooms = yield(self,"open_games_listed")
	join_game_doalog.list_servers(rooms)

func list_open_games():
	var result:Array
	Firebase.Firestore.list("OpenGames")
	var docs = yield(Firebase.Firestore,"listed_documents")
	var docname:String
	for doc in docs["documents"]:
		docname = doc["name"].rsplit("/",true,1)[1]
		result.append(docname)
	emit_signal("open_games_listed",result)
	
func _get_game(Adress):
	Open_Games.get(Adress)
	var game:FirestoreDocument = yield(Open_Games,"get_document")
	game.fields2dict(game)
	emit_signal("got_game",game)
	
