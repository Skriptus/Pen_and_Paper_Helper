extends PanelContainer

func create(Dict:Dictionary,pos:Vector2):
	var text:String = ""
	for key in Dict.keys():
		text += "[b]"+ key +":[/b] "+ String(Dict[key])+"\n"
	set_position(pos)
	$RichTextLabel.bbcode_text = text
	print(pos)
	show()

func remove():
	hide()
