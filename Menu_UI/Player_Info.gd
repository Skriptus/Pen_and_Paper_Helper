extends Control

var Level = 0
var roman_bool

var parent:Node
var user_doc:FirestoreDocument
onready var Username_dialog = $Username
onready var Friendlist = $CenterContainer/Friends/Friends
onready var levellabel = $CenterContainer/VBoxContainer/HBoxContainer/Level
onready var change_username_b = $CenterContainer/VBoxContainer/HBoxContainer/Name/Optionspanel/Options/Change_name
onready var name_options = $CenterContainer/VBoxContainer/HBoxContainer/Name/Optionspanel


func set_name_number(Name:String,Number:int):
	$CenterContainer/VBoxContainer/HBoxContainer/Name.text = Name + " #" + String(Number)

func set_level_progress(experience:int,roman:bool):
	roman_bool = roman
	Level = floor(experience/50)
	var progress = (experience/50)-Level
	var Leveltext
	if roman:
		Leveltext = roman_numbers(Level)
	else:
		Leveltext = String(Level)
	$CenterContainer/VBoxContainer/HBoxContainer/Level.text = String(Leveltext)
	$CenterContainer/VBoxContainer/Levelprogress.value = progress

func roman_numbers(Nummer) -> String:
	var Text = ""
	var M = floor(float(Nummer)/1000)
	var D = floor(float(Nummer-(M*1000))/500)
	var C = floor(float(Nummer-(M*1000)-(D*500))/100)
	var L = floor(float(Nummer-(M*1000)-(D*500)-(C*100))/50)
	var X = floor(float(Nummer-(M*1000)-(D*500)-(C*100)-(L*50))/10)
	var V = floor(float(Nummer-(M*1000)-(D*500)-(C*100)-(L*50)-(X*10))/5)
	var I = floor(float(Nummer-(M*1000)-(D*500)-(C*100)-(L*50)-(X*10)-(V*5)))
	for n in range(M):
		Text += "M"
	for n in range(D):
		Text += "D"
	if C == 4:
		Text += "CD"
	else:
		for n in range(C):
			Text += "C"
	for n in range(L):
		Text += "L"
	if X == 4:
		Text += "XL"
	else:
		for n in range(X):
			Text += "X"
	for n in range(V):
		Text += "V"
	if I == 4:
		Text += "IV"
	else:
		for n in range(I):
			Text += "I"
	if Text == "":
		Text = "0"
	return Text

func _on_Level_pressed():
	var Leveltext
	if roman_bool:
		roman_bool = false
		Leveltext = String(Level)
	else:
		roman_bool = true
		Leveltext = roman_numbers(Level)
	levellabel.text = String(Leveltext)

func _on_Friends_pressed():
	if Friendlist.visible:
		Friendlist.hide()
	else:
		Friendlist.show()


func _on_Change_name_pressed():
	name_options.hide()
	Username_dialog.popup()
	Username_dialog.allow_close = true
	var new_name = yield(Username_dialog,"new_username")
	Collections.update_nickname(parent.email,new_name)
	yield(Collections,"got_nickname")
	var new_doc = yield(Collections,"got_nickname")
	set_name_number(new_doc.doc_fields["Name"],new_doc.doc_fields["Number"])

func _on_show_qr_pressed():
	name_options.hide()


func _on_Name_toggled(button_pressed):
	if button_pressed:
		if Network.peer != null:
			change_username_b.hide()
		name_options.show()
	else:
		name_options.hide()
		change_username_b.show()

func _on_Player_Info_visibility_changed():
	yield(get_tree().create_timer(0.5),"timeout")
	var fields = parent.User_doc.doc_fields
	for item in fields["Requestby"]:
		Collections.get_nickname(item)
		var usr_dict = yield(Collections,"got_nickname")
		var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
		User.name = usr_dict.doc_fields["Name"]
		Friendlist.request.add_child(User)
		User.fill(usr_dict.doc_fields,"name")
	for item in fields["Requested"]:
		Collections.get_nickname(item)
		var usr_dict = yield(Collections,"got_nickname")
		var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
		User.name = usr_dict.doc_fields["Name"]
		Friendlist.request.add_child(User)
		User.fill(usr_dict.doc_fields,"name")
	if Friendlist.request.get_child_count() > 0:
		Friendlist.request_con.show()
