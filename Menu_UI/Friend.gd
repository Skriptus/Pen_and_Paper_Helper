extends Panel

onready var Name_label:RichTextLabel = $Info/Name

func fill(dict:Dictionary,found_type):
	match found_type:
		"email":
			Name_label.bbcode_text = "[b]"+dict["Email"]+"[/b]"
		"number":
			Name_label.bbcode_text = dict["Name"]+"#[b]"+String(dict["Number"])+"[/b]"
		"name":
			Name_label.bbcode_text = "[b]"+dict["Name"]+"[/b]#"+String(dict["Number"])


func _on_Add_pressed():
	pass # Replace with function body.


func _on_Join_pressed():
	pass # Replace with function body.


func _on_Message_pressed():
	pass # Replace with function body.


func _on_Remove_pressed():
	pass # Replace with function body.
