extends Panel

var Nametext 

func fill(Portrait:Texture,Name:String,Level:String):
	Nametext = Name
	var Namelabel = Name
	if Namelabel.length() > 15:
		Namelabel = Name.substr(0,12) + "..."
	$HBoxContainer/Portrait.texture = Portrait
	$HBoxContainer/Name.text = Namelabel
	$HBoxContainer/Level.text = Level
