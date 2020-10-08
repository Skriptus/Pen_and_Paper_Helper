extends Spatial

var My_playermesh
var Anchors
var Players_array:Array #[Node,pos,id]

func _init():
	Anchors = $Anchors
	set_network_master(1)
	if get_tree().is_network_server():
		My_playermesh = preload("res://Player/Playermesh.tscn").instance()
		$Anchors/HostPos.add_child(My_playermesh)
		My_playermesh.Cam.current = true
		Players_array.append([My_playermesh,"HostPos",Network.own_id])

slave func load_other_players(Players_ar):
	for ply in Players_ar:
		if ply[2] == Network.own_id:
			continue
		else:
			add_playermesh(ply[1],ply[2])

func _player_joined(id):
	for i in range(Network.game_dict["Max_players"]):
		var posname = "Pos"
		posname += String(i+1)
		if Anchors.get_node(posname).get_child_count() == 0:
			rpc("add_playermesh",posname,id)
			break
	rpc_id(id,"load_other_players",Players_array)
	
sync func _player_left(id):
	for ply in Players_array:
		if ply[2] == id:
			ply[0].queue_free()
			Players_array.remove(Players_array.find(ply))
	
sync func add_playermesh(pos,id):
	var Playermesh = preload("res://Player/Playermesh.tscn").instance()
	Players_array.append([Playermesh,pos,id])
	Anchors.get_node(pos).add_child(Playermesh)
	Playermesh.set_network_master(id)
	if id == Network.own_id:
		Playermesh.Cam.current = true
	
