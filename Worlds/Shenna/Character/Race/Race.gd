extends Node

var character_race:Object
var player_character:Object
var possible_races:Array = ["ATRA","DWARF","FAIRY","FROZEN","HULL","HUMAN","JADEGHOST","OUTGROWN","RIVERRUN"]

func _ready():
	pass

func select_race(racename):
	if character_race:
		remove_race_stats()
	character_race = get_node(racename)
	add_race_stats()
	
func remove_race_stats():
	player_character.health -= character_race.health
	player_character.energy -= character_race.energy
	player_character.karma -= character_race.karma
	player_character.strength -= character_race.strenght
	player_character.agility -= character_race.agility
	player_character.resistance -= character_race.resistance
	player_character.perception -= character_race.perception
	player_character.intelligence -= character_race.intelligence
	player_character.wisdom -= character_race.wisdom
	player_character.aura -= character_race.aura
	player_character.faith -= character_race.faith
	player_character.ego -= character_race.ego
func add_race_stats():
	player_character.health += character_race.health
	player_character.energy += character_race.energy
	player_character.karma += character_race.karma
	player_character.strength += character_race.strenght
	player_character.agility += character_race.agility
	player_character.resistance += character_race.resistance
	player_character.perception += character_race.perception
	player_character.intelligence += character_race.intelligence
	player_character.wisdom += character_race.wisdom
	player_character.aura += character_race.aura
	player_character.faith += character_race.faith
	player_character.ego += character_race.ego
