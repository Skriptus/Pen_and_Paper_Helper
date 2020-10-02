extends Popup

onready var name_line:LineEdit  = $Panel/VBoxContainer/Name/Name_line
onready var world_b:OptionButton = $Panel/VBoxContainer/World/World_option
onready var room_b:OptionButton  = $Panel/VBoxContainer/Rooms/Room_options
onready var max_p_b:OptionButton  = $Panel/VBoxContainer/Max_Players/Max_players_option
onready var notification = $Panel/VBoxContainer/Notification
onready var parent = get_parent()

func _ready():
	var file = File.new()
	file.open("res://Worlds/Worlds.txt",file.READ)
	while !file.eof_reached():
		world_b.add_item(file.get_line ())
	file.close()
	file.open("res://Rooms/Rooms.txt",file.READ)
	while !file.eof_reached():
		var room = file.get_line().split(",")
		room_b.add_item(room[0])
		for i in range(room[1]):
			max_p_b.add_item(String(i+1))
		max_p_b.select(int(room[1])-1)
	file.close()

func _on_Host_pressed():
	if Badwords._check_word(name_line.text) && name_line.text != "":
		parent.Host_game(name_line.text,world_b.get_item_text(world_b.selected),int(max_p_b.get_item_text(max_p_b.selected)),room_b.text)
		self.hide()

func _on_Name_line_text_changed(new_text):
	if Badwords._check_word(new_text):
		notification.text = ""
		notification.hide()
	else:
		notification.text = "BADWORD_ENTERD"
		notification.show()
