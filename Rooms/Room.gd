extends Spatial

var Player_Anchors
var Character_Anchors
var Players_array:Array #[Node,pos,id]

func _init():
	Player_Anchors = $Player_Anchors
	Character_Anchors = $Character_Anchors
	set_network_master(1)
	if get_tree().is_network_server():
		add_playermesh("PosHost",1)

puppet func load_other_players(Players_ar):
	for ply in Players_ar:
		if ply[2] == Network.own_id:
			continue
		else:
			add_playermesh(ply[1],ply[2])

master func _player_joined(id):
	for i in range(Network.game_dict["Max_players"]):
		var posname = "Pos"
		posname += String(i+1)
		if Player_Anchors.get_node(posname).get_child_count() == 0:
			rpc("add_playermesh",posname,id)
			break
	rpc_id(id,"load_other_players",Players_array)
	
sync func _player_left(id):
	for ply in Players_array:
		if ply[2] == id:
			ply[0].queue_free()
			Players_array.remove(Players_array.find(ply))
	
sync func add_playermesh(pos,id):
	var Playermesh = preload("res://Player/Player_actor.tscn").instance()
	Players_array.append([Playermesh,pos,id])
	Player_Anchors.get_node(pos).add_child(Playermesh)
	Playermesh.set_network_master(id)
	if id == Network.own_id:
		Playermesh.Cam.current = true
		Playermesh.add_GUI()
		Playermesh.GUI.room = self
