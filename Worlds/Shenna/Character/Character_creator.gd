extends PanelContainer

onready var Baseinfo = $VBC/TabContainer/BASEINFO
onready var Basestats = $VBC/TabContainer/BASESTATS
onready var Available_points = $VBC/TabContainer/BASESTATS/Available_points/Points
onready var Weaponpoints = $VBC/TabContainer/WEAPONSTATS/WEAPONPOINTS/points
onready var Attack = $VBC/TabContainer/WEAPONSTATS/ATTACK
onready var Parry = $VBC/TabContainer/WEAPONSTATS/PARRY
onready var Astralenergy = $VBC/TabContainer/WEAPONSTATS/ASTRALENERGY
onready var Astralconcentration = $VBC/TabContainer/WEAPONSTATS/ASTRALKONCENTRATION
onready var Singlehaded = $VBC/TabContainer/WEAPONSTATS/PHYSICAL/PHYSICAL/SINGLEHANDED
onready var Twohanded = $VBC/TabContainer/WEAPONSTATS/PHYSICAL/PHYSICAL/TWOHANDED
onready var Staffweapons = $VBC/TabContainer/WEAPONSTATS/PHYSICAL/PHYSICAL/STAFFWEAPONS
onready var Distance = $VBC/TabContainer/WEAPONSTATS/PHYSICAL/PHYSICAL/DISTANCE
onready var Elements = $VBC/TabContainer/WEAPONSTATS/MAGICAL/MAGICAL/ELEMENTS
onready var Energymagic = $VBC/TabContainer/WEAPONSTATS/MAGICAL/MAGICAL/ENERGYMAGIC
onready var Summon = $VBC/TabContainer/WEAPONSTATS/MAGICAL/MAGICAL/SUMMON

func _ready():
	Attack.get_node("Plus").connect("pressed",self,"increase_stat",[Attack])
	Attack.get_node("Minus").connect("pressed",self,"decrease_stat",[Attack])
	Parry.get_node("Plus").connect("pressed",self,"increase_stat",[Parry])
	Parry.get_node("Minus").connect("pressed",self,"decrease_stat",[Parry])
	Astralenergy.get_node("Plus").connect("pressed",self,"increase_stat",[Astralenergy])
	Astralenergy.get_node("Minus").connect("pressed",self,"decrease_stat",[Astralenergy])
	Astralconcentration.get_node("Plus").connect("pressed",self,"increase_stat",[Astralconcentration])
	Astralconcentration.get_node("Minus").connect("pressed",self,"decrease_stat",[Astralconcentration])
	for stat in Basestats.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Singlehaded.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Twohanded.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Staffweapons.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Distance.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Elements.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Energymagic.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])
	for stat in Summon.get_children():
		if stat.has_node("Plus"):
			stat.get_node("Plus").connect("pressed",self,"increase_stat",[stat])
			stat.get_node("Minus").connect("pressed",self,"decrease_stat",[stat])

func increase_stat(stat):
	var value = int(stat.get_node("value").text)
	if $VBC/TabContainer.current_tab == 1:
		if int(Available_points.text) > 0:
			stat.get_node("value").text = String(value+1)
			Available_points.text = String(int(Available_points.text)-1)
	else:
		if int(Weaponpoints.text) > 0:
			stat.get_node("value").text = String(value+1)
			Weaponpoints.text = String(int(Weaponpoints.text)-1)
func decrease_stat(stat):
	var value = int(stat.get_node("value").text)
	if $VBC/TabContainer.current_tab == 1:
		if value > 0 && int(Available_points.text) <= 10:
			stat.get_node("value").text = String(value-1)
			Available_points.text = String(int(Available_points.text)+1)
	else:
		if value > 0 && int(Weaponpoints.text) <= 20:
			stat.get_node("value").text = String(value-1)
			Weaponpoints.text = String(int(Weaponpoints.text)+1)


func _on_CONTINUE_pressed():
	if $VBC/TabContainer.current_tab < $VBC/TabContainer.get_tab_count()-1:
		$VBC/TabContainer.current_tab += 1
	else:
		var dict = {
			"ATTACK" : Attack.get_node("value").text,
			"PARRY" : Parry.get_node("value").text,
			"ASTRALENERGY" : Astralenergy.get_node("value").text,
			"ASTRALCONCENTRATION" : Astralconcentration.get_node("value").text
			}
		for stat in Baseinfo.get_children():
			var child = stat.get_child(1)
			var value
			if child is LineEdit:
				value = child.text
			if child is SpinBox:
				value = child.value
			if child is OptionButton:
				value = child.text
			dict[stat.name] = value
		for stat in Basestats.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Singlehaded.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Twohanded.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Staffweapons.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Distance.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Elements.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Energymagic.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		for stat in Summon.get_children():
			if stat.has_node("value"):
				dict[stat.name] = stat.get_node("value").text
		var character_actor = preload("res://Worlds/Shenna/Character/Character_actor.tscn").instance()
		Network.parent.room.Character_Anchors.get_node("Pos1").add_child(character_actor)
		character_actor.character_dict = dict
		self.hide()

func _on_TabContainer_tab_changed(tab):
	if tab == $VBC/TabContainer.get_tab_count()-1:
		$VBC/CONTINUE.text = "FINISH"
	else:
		$VBC/CONTINUE.text = "CONTINUE"
