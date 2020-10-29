extends Spatial

var Player_Anchors
var Character_Anchors
var Players_array:Array #[Node,pos,id]
var parent
var host
var GUI
var My_Player_actor

func _init():
	parent = get_parent()
	Player_Anchors = $Player_Anchors
	Character_Anchors = $Character_Anchors
	set_network_master(1)

func get_pos():
	for i in range(parent.game_dict["Max_players"]):
		var posname = "Pos"
		posname += String(i+1)
		if Player_Anchors.get_node(posname).get_child_count() == 0:
			return posname
			
func add_player(User):
	print(User)
	

func remove_player(User):
	print(User)

func add_host():
	add_actor("PosHost",1)
func update_host(host_info):
	host = host_info
	

sync func add_actor(pos,id):
	var Player_actor = preload("res://Main/Player_actor.tscn").instance()
	Player_actor.parent = parent
	Player_actor.room = self
	Player_Anchors.get_node(pos).add_child(Player_actor)
	Player_actor.set_network_master(id)
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
	GUI.connect("gui_input",My_Player_actor,"on_gui_input")
