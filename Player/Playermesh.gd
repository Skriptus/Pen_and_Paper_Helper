extends Spatial

onready var Cam = $Head/Camera
onready var Body = $Body
onready var Head = $Head
var pos:Vector3
var rot:Vector3
var state := "Idle"

func _ready():
	$Head/Camera/Player_GUI.connect("gui_input",self,"on_gui_input")

slave func set_body_pos_rot_state(_position:Vector3,_rotation:Vector3,_state:String):
	Body.translation = _position
	Body.rotation = _rotation
	state = _state
	
slave func set_head_pos_rot_state(_rotation:Vector3):
	Head.rotation = _rotation

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_pressed("ui_down"):
			translate(Vector3(0,0,-0.1))
		if Input.is_action_pressed("ui_up"):
			translate(Vector3(0,0,0.1))
		if Input.is_action_pressed("ui_right"):
			translate(Vector3(0.1,0,0))
		if Input.is_action_pressed("ui_left"):
			translate(Vector3(-0.1,0,0))
		
	rpc("set_pos_rot_state",translation,rotation,"idle")

func on_gui_input(event):
	if event is InputEventScreenDrag:
		var _yaw = event.relative.x
		var _pitch = event.relative.y
		Head.rotate_y(deg2rad(_yaw))
		Head.rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
