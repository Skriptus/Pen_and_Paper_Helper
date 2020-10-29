extends PanelContainer

onready var TT:RichTextLabel = $TT

signal fill_data(info_node)

func _on_Frient_TT_fill_data(info_node):
	TT.bbcode_text = ""
	var length := 0
	var lines := 0
	if info_node.TT_dict.keys().has("Title"):
		var line:String = "[b][center]"+info_node.TT_dict["Title"]+"[/center][/b]"+ "\n"
		TT.bbcode_text += line
		if line.length() > length:
			length = line.length()
		lines += 1
	for key in info_node.TT_dict.keys():
		if key == "Title"||key == "Description":
			continue
		var line:String = key + ": " + String(info_node.TT_dict[key])+ "\n"
		TT.bbcode_text += line
		if line.length() > length:
			length = line.length()
		lines += 1
	if info_node.TT_dict.keys().has("Description"):
		TT.bbcode_text += info_node.TT_dict["Description"]
		var descriptionsegments = info_node.TT_dict["Description"].split("\n")
		for seg in descriptionsegments:
			if seg.length() > length:
				length = seg.length()
		lines += 1
	self.rect_size.y = lines * 22
	self.rect_size.x = length * 5
