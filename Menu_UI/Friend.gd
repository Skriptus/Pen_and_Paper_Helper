extends Control

onready var Name_label:RichTextLabel = $Info/Name

func fill(dict:Dictionary,found_type):
	print(dict,found_type)
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
	pass # Replace with function body.


func _on_Join_pressed():
	pass # Replace with function body.


func _on_Message_pressed():
	pass # Replace with function body.


func _on_Remove_pressed():
	pass # Replace with function body.

func _gui_input(event):
	#print(event)
	pass


func _on_Name_mouse_entered():
	Tooltip.create()

func _on_Name_mouse_exited():
	pass # Replace with function body.

