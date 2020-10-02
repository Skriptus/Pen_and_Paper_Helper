extends Control

var Level
var roman_bool
var self_info

var parent:player
var user_doc:FirestoreDocument
onready var change_username_dialog = $Change_username
onready var Username_dialog = $Username

func _ready():
	$Change_username/Panel/VBoxContainer/HBoxContainer/No.connect("pressed",self,"_change_no_pressed")
	$Change_username/Panel/VBoxContainer/HBoxContainer/Yes.connect("pressed",self,"_change_yes_pressed")
	user_doc = yield(get_parent(),"got_user")
	self_info = parent._get_Nickname(user_doc.doc_name)[0]
	if self_info["Name"]:
		set_name_number(self_info["Name"],String(self_info["Number"]))
		set_level_progress(user_doc.doc_fields["Experience"],true)
	else:
		Username_dialog.popup()
		var new_name = yield(Username_dialog,"new_username")
		parent._update_Nickname(new_name)
		var n = yield(parent,"Nickname_updated")
		set_name_number(n[0],String(n[1]))


func set_name_number(Name:String,Number:String):
	$CenterContainer/VBoxContainer/HBoxContainer/Name.text = Name + " #" + Number

func set_level_progress(experience:String,roman:bool):
	roman_bool = roman
	Level = floor(float(experience)/50)
	var progress = (float(experience)/50)-Level
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
	return Text

func _on_Name_pressed():
	$Change_username.popup()
	Username_dialog.allow_close = true
	var new_name = yield(Username_dialog,"new_username")
	parent._update_Nickname(new_name)
	var n = yield(parent,"Nickname_updated")
	set_name_number(n[0],String(n[1]))

func _on_Level_pressed():
	var Leveltext
	if roman_bool:
		roman_bool = false
		Leveltext = String(Level)
	else:
		roman_bool = true
		Leveltext = roman_numbers(Level)
	$HBoxContainer/VBoxContainer/HBoxContainer/Level.text = String(Leveltext)

func _change_yes_pressed():
	Username_dialog.popup()
	change_username_dialog.hide()

func _change_no_pressed():
	change_username_dialog.hide()



func _on_Player_Info_gui_input(event):
	print(event) # Replace with function body.


func _on_Friends_pressed():
	pass # Replace with function body.
