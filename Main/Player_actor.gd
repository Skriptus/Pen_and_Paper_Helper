extends Spatial

onready var Cam = $Head/Camera
onready var Body = $Head/Body
onready var Head = $Head
onready var shadow = $Head_shadow
var pos:Vector3
var rot:Vector3
var state := "Idle"
var GUI
var parent
var room

var original_Pos

var TT_dict:Dictionary

func _ready():
	original_Pos = Head.translation

puppet func set_body_pos_rot_state(_position:Vector3,_rotation:Vector3,_state:String):
	Body.translation = _position
	Body.rotation = _rotation
	state = _state
	
puppet func set_head_pos(_position:Vector3):
	Head.translation = _position
	set_shadow()
puppet func set_head_rot(_rotation):
	Head.rotation = _rotation

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_pressed("ui_down"):
			Head.translate(Vector3(0,-010,0))
		if Input.is_action_pressed("ui_up"):
			Head.translate(Vector3(0,010,0))
		if Input.is_action_pressed("ui_right"):
			Head.translate(Vector3(-010,0,0))
		if Input.is_action_pressed("ui_left"):
			Head.translate(Vector3(10,0,0))
		set_shadow()
		rpc_unreliable("set_head_pos",Head.translation)

func on_gui_input(event):
	if event is InputEventScreenDrag:
		var _yaw = event.relative.x/3
		var _pitch = event.relative.y/3
		Head.rotate_y(deg2rad(_yaw))
		Head.rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
		rpc_unreliable("set_head_rot",Head.rotation)

func set_shadow():
	if Head.translation.distance_to(shadow.translation) >1.0:
		shadow.show()
	else:
		shadow.rotation = Head.rotation
		shadow.hide()
