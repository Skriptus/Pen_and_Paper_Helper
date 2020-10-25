extends Control

onready var Name_label:RichTextLabel = $Vbox/Name
onready var Status_label:Label = $Vbox/Sort/Info/Status
var Nickname_dict
onready var message = $Vbox/Sort/Actions/Message
onready var join = $Vbox/Sort/Actions/Join
onready var invite = $Vbox/Sort/Actions/Invite
onready var add = $Vbox/Sort/Actions/Add
onready var remove = $Vbox/Sort/Actions/Remove
onready var accept = $Vbox/Sort/Actions/Accept
onready var decline = $Vbox/Sort/Actions/Decline
onready var email = Network.parent.email
onready var own_usr_doc = Network.parent.User_doc

var TT_dict
var list

func fill(dict:Dictionary,found_type):
	Nickname_dict = dict
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
	var me = false
	var jo = false
	var iv = false
	var ad = false
	var re = false
	var ac = false
	var de = false
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
		"Online":
			me = true
			message.show()
			re = true
			remove.show()
			iv = true
			invite.show()
			color = Color.green
		"FOUND":
			ad = true
			add.show()
			color = Color.lightcoral
			status = ""
		"Ingame":
			me = true
			message.show()
			re = true
			remove.show()
			jo = true
			join.show()
			color = Color.lightcyan
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
	var User_to_add
	Collections.get_user(Nickname_dict["Email"])
	User_to_add = yield(Collections,"got_user")
	User_to_add.doc_fields["Requestby"].append(email)
	Collections.update_user(Nickname_dict["Email"],User_to_add.doc_fields)
	User_to_add = yield(Collections,"got_user")
	own_usr_doc.doc_fields["Requested"].append(Nickname_dict["Email"])
	Collections.update_user(email,own_usr_doc.doc_fields)
	own_usr_doc = yield(Collections,"got_user")
	list.Update_list()


func _on_Join_pressed():
	print("join")

func _on_Message_pressed():
	print("messsage")

func _on_Remove_pressed():
	print("remove")

func _on_Decline_pressed():
	Collections.get_user(Nickname_dict["Email"])
	var usr = yield(Collections,"got_user")
	var usr_doc = usr.doc_fields
	if usr_doc["Requested"].has(email):
		usr_doc["Requested"].remove(usr_doc["Requested"].find(email))
		usr_doc["Blockedby"].append(email)
		Collections.update_user(Nickname_dict["Email"],usr_doc)
		yield(Collections,"got_user")
	if own_usr_doc.doc_fields["Requestby"].has(Nickname_dict["Email"]):
		own_usr_doc.doc_fields["Requestby"].remove(own_usr_doc.doc_fields["Requestby"].find(Nickname_dict["Email"]))
		own_usr_doc.doc_fields["Blocked"].append(Nickname_dict["Email"])
		Collections.update_user(email,own_usr_doc.doc_fields)
		yield(Collections,"got_user")
	

func _on_Accept_pressed():
	Collections.get_user(Nickname_dict["Email"])
	var usr = yield(Collections,"got_user")
	var usr_doc = usr.doc_fields
	if usr_doc["Requested"].has(email):
		usr_doc["Requested"].remove(usr_doc["Requested"].find(email))
		usr_doc["Friends"].append(email)
		Collections.update_user(Nickname_dict["Email"],usr_doc)
		yield(Collections,"got_user")
	if own_usr_doc.doc_fields["Requestby"].has(Nickname_dict["Email"]):
		own_usr_doc.doc_fields["Requestby"].remove(own_usr_doc.doc_fields["Requestby"].find(Nickname_dict["Email"]))
		own_usr_doc.doc_fields["Friends"].append(Nickname_dict["Email"])
		Collections.update_user(email,own_usr_doc.doc_fields)
		yield(Collections,"got_user")
	
func _on_Invite_pressed():
	print("invite")


func _on_Name_mouse_exited():
	Modular_Tooltip

func _on_Name_mouse_entered():
	var rect = self.get_global_rect().position
