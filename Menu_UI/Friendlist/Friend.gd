extends Control

onready var Name_label:RichTextLabel = $Vbox/Name
onready var Status_label:Label = $Vbox/Sort/Info/Status
onready var message = $Vbox/Sort/Actions/Message
onready var join = $Vbox/Sort/Actions/Join
onready var invite = $Vbox/Sort/Actions/Invite
onready var add = $Vbox/Sort/Actions/Add
onready var remove = $Vbox/Sort/Actions/Remove
onready var accept = $Vbox/Sort/Actions/Accept
onready var decline = $Vbox/Sort/Actions/Decline

var TT_dict
var list

func fill(dict:Dictionary,found_type):
	var name_text:String = dict["Name"]
	var number_text = String(dict["Number"])
	if name_text.length() >= 20:
		name_text = name_text.substr(0,5)+"..."
	match found_type:
		"email":
			Name_label.bbcode_text = "[center][b]"+dict["Email"]+"[/b][/center]"
		"number":
			Name_label.bbcode_text = "[center]" + name_text+"[b]#"+number_text+"[/b][/center]"
		"name":
			Name_label.bbcode_text = "[center][b]"+name_text+"[/b]#"+number_text+"[/center]"
	TT_dict = {
		"Title" : dict["Name"],
		"Number" : dict["Number"],
		"Email" : dict["Email"]
	}
func set_status(status:String):
	var me = false #message
	var jo = false #join
	var iv = false #invite
	var ad = false #add
	var re = false #remove
	var ac = false #accept
	var de = false #decline
	var color:Color = Color.lightgray
	match status:
		"REQUESTEDBY":
			ac = true
			accept.show()
			de = true
			decline.show()
			color = Color.greenyellow
		"REQUESTED":
			color = Color.lightblue
		"ONLINE":
			me = true
			message.show()
			re = true
			remove.show()
			iv = true
			invite.show()
			color = Color.green
		"OFFLINE":
			me = true
			message.show()
			re = true
			remove.show()
			color = Color.darkgray
		"FOUND":
			ad = true
			add.show()
			color = Color.lightcoral
			status = ""
		"INGAME":
			me = true
			message.show()
			re = true
			remove.show()
			jo = true
			join.show()
			color = Color.lightcyan
		"HOSTING":
			me = true
			message.show()
			re = true
			remove.show()
			jo = true
			join.show()
			color = Color.lightskyblue
	Status_label.set("custom_colors/font_color", color)
	Status_label.text = status
	if not me:
		message.hide()
	if not jo:
		join.hide()
	if not iv:
		invite.hide()
	if not ad:
		add.hide()
	if not re:
		remove.hide()
	if not ac:
		accept.hide()
	if not de:
		decline.hide()

func _on_Add_pressed():
	print("add")

func _on_Join_pressed():
	print("join")

func _on_Message_pressed():
	print("messsage")

func _on_Remove_pressed():
	print("remove")

func _on_Decline_pressed():
	print("decline")
	

func _on_Accept_pressed():
	print("accept")
	
func _on_Invite_pressed():
	print("invite")

