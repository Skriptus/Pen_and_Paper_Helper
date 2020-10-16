extends Control

onready var Name_label:RichTextLabel = $Sort/Info/Name
var Nickname_dict

func fill(dict:Dictionary,found_type):
	Nickname_dict = dict
	var name_text:String = dict["Name"]
	var number_text = String(dict["Number"])
	if name_text.length() >= 8:
		name_text = name_text.substr(0,5)+"..."
	match found_type:
		"email":
			Name_label.bbcode_text = "[b]"+dict["Email"]+"[/b]"
		"number":
			Name_label.bbcode_text = name_text+"[b]#"+number_text+"[/b]"
		"name":
			Name_label.bbcode_text = "[b]"+name_text+"[/b]#"+number_text

func _on_Add_pressed():
	var User_to_add
	Collections.get_user(Nickname_dict["Email"])
	User_to_add = yield(Collections,"got_user")
	User_to_add.doc_fields["Requestby"].append(Network.parent.email)
	Collections.update_user(Nickname_dict["Email"],User_to_add.doc_fields)
	User_to_add = yield(Collections,"got_user")
	Network.parent.User_doc.doc_fields["Requested"].append(Nickname_dict["Email"])
	Collections.update_user(Network.parent.email,Network.parent.User_doc.doc_fields)
	Network.parent.User_doc = yield(Collections,"got_user")


func _on_Join_pressed():
	pass # Replace with function body.


func _on_Message_pressed():
	pass # Replace with function body.

func _on_Remove_pressed():
	pass # Replace with function body.

