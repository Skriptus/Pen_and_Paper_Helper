extends Node

onready var Panelcon:PanelContainer = $Panelcon

func fill(Dict:Dictionary,pos:Vector2):
	var lines = 0
	var max_length = 0
	var text:String = ""
	if Dict.keys().has("Title"):
		text += "[center][b]"+ Dict["Title"] +"[/b][/center]"+"\n"
		lines += 1
	for key in Dict.keys():
		if (key.length() + String(Dict[key]).length()) >= max_length:
			max_length = (key.length() + String(Dict[key]).length())
		if key == "Title" || key == "Description":
			continue
		text += "[b]"+ key +":[/b] "+ String(Dict[key])+"\n"
		lines += 1
	if Dict.keys().has("Description"):
		text += Dict["Description"]
		lines += 1
	$Panelcon/RichTextLabel.bbcode_text = text
	#set size and position
	var width = get_viewport().size.x
	if pos.x <= width/2:
		Panelcon.margin_right = pos.x + (max_length*10)
		Panelcon.margin_left = pos.x 
	else:
		Panelcon.margin_right = pos.x
		Panelcon.margin_left = pos.x - (max_length*10)

	var hight = get_viewport().size.y
	if pos.y >= hight/2:
		Panelcon.margin_top = pos.y - (lines*35)
		Panelcon.margin_bottom = pos.y
	else:
		Panelcon.margin_top = pos.y
		Panelcon.margin_bottom = pos.y + (lines*35)
	Panelcon.show()
