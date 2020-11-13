extends Spatial

var Player_Anchors:Spatial
var Character_Anchors:Spatial
var Players_dict:Dictionary  #id:[Node,pos,dict]
var parent
var GUI
var Lobby
var My_Player_actor

func _init():
	parent = get_parent()
	Player_Anchors = $Player_Anchors
	Character_Anchors = $Character_Anchors
	set_network_master(1)

puppet func set_Players_dict(dict):
	for id in Players_dict.keys():
		if dict.keys().has(id):
			continue
		else:
			Players_dict.erase(id)
	for id in dict.keys():
		if Players_dict.keys().has(id):
			continue
		else:
			add_actor(dict[id][1],id)
	Players_dict = dict
	Lobby.update()

func get_pos(max_players):
	for i in range(max_players):
		var posname = "Pos"
		posname += String(i+1)
		if Player_Anchors.get_node(posname).get_child_count() == 0:
			return posname

func remove_player(id):
	var node = Players_dict[id][0]
	Players_dict.erase(id)
	node.queue_free()

sync func add_actor(pos,id):
	var Player_actor = preload("res://Main/Player_actor.tscn").instance()
	Player_actor.parent = parent
	Player_actor.room = self
	Player_Anchors.get_node(pos).add_child(Player_actor)
	Player_actor.name = String(id)
	Player_actor.set_network_master(id)
	if not id == parent.own_id:
		Players_dict[id] = [Player_actor,pos,null]
	if id == parent.own_id:
		My_Player_actor = Player_actor
		Player_actor.Cam.current = true
		add_GUI()
		
func add_GUI():
	if get_tree().is_network_server():
		GUI = preload("res://Menu_UI/User_GUI/Host_GUI.tscn").instance()
	else:
		GUI = preload("res://Menu_UI/User_GUI/Player_GUI.tscn").instance()
	GUI.parent = parent
	GUI.room = self
	My_Player_actor.Cam.add_child(GUI)
	Lobby = preload("res://Menu_UI/Multiplayer/Lobby.tscn").instance()
	GUI.add_child(Lobby)
	Lobby.room = self
	Lobby.update()
	GUI.connect("gui_input",My_Player_actor,"on_gui_input")

sync func add_character(dict,id):
	var pos = Character_Anchors.get_node(Players_dict[id][1])
	var Charercter = preload("res://Worlds/Shenna/Character/Character.tscn").instance()
	pos.add_child(Charercter)
	Charercter.set_network_master(id)
	Charercter.character_dict = dict
