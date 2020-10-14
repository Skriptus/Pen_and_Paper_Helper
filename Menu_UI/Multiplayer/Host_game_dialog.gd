extends Popup

onready var name_line:LineEdit  = $Panel/VBoxContainer/Name/Name_line
onready var world_b:OptionButton = $Panel/VBoxContainer/World/World_option
onready var room_b:OptionButton  = $Panel/VBoxContainer/Rooms/Room_options
onready var max_p_b:OptionButton  = $Panel/VBoxContainer/Max_Players/Max_players_option
onready var notification = $Panel/VBoxContainer/Notification
onready var host_b:Button = $Panel/VBoxContainer/Host

var IPaddress:String
var used_names:Array
var room_array:Array

func _ready(): #get available Worlds and room / recieve Ip Address
	var file = File.new()
	file.open("res://Worlds/Worlds.res",file.READ)
	while !file.eof_reached():
		world_b.add_item(file.get_line ())
	file.close()
	file.open("res://Rooms/Rooms.res",file.READ)
	while !file.eof_reached():
		var room = file.get_line().split(",")
		room_array.append(room)
	file.close()
	for room in room_array:
		room_b.add_item(room[0])
	room_b.select(0)
	_on_Room_options_item_selected(0)
	
	var IPRequest = HTTPRequest.new()
	self.add_child(IPRequest)
	IPRequest.request("https://api.ipify.org")
	var result = yield(IPRequest,"request_completed")
	IPaddress = result[3].get_string_from_utf8()
	IPRequest.queue_free()

func _on_Host_pressed():
	if Badwords._check_word(name_line.text) && name_line.text != "":
		var Game:Dictionary = {
		"IP" : IPaddress,
		"Max_players" : int(max_p_b.get_item_text(max_p_b.selected)),
		"Name" : name_line.text,
		"PORT" : 4242,
		"current_players" : 0,
		"Room" : room_b.get_item_text(room_b.selected),
		"World" : world_b.get_item_text(world_b.selected)
		}
		Network.start_host(Game)
		Collections.add_game(Game)
		self.hide()
		
func _on_Name_line_text_changed(new_text):
	Collections.list("OpenGames")
	used_names = yield(Collections,"got_list")
	if !Badwords._check_word(new_text) :
		notification.text = "BADWORD_ENTERD"
		host_b.disabled = true
		notification.show()
	elif used_names.has(new_text):
		notification.text = "NAME_USED"
		host_b.disabled = true
		notification.show()
	else:
		notification.text = ""
		host_b.disabled = false
		notification.hide()
	
func _on_Room_options_item_selected(id):
	max_p_b.clear()
	for n in int(room_array[id][1]):
		max_p_b.add_item(String(n+1))
	max_p_b.select(int(room_array[id][1])-1)
