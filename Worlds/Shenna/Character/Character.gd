extends Node

class_name character

##### General Info #####

var character_name:String
onready var character_stats:Object = $Stats
onready var character_race:Object = $Race
onready var character_class:Object = $Class
onready var character_sex:Object = $Sex
onready var character_inventory:Object = $Inventory

##### Game stats #####

var allies:Array = []
var enemies:Array = []
var character_player:Object
var position:Array = [[0,0],[0,0]] #overworldpostiotion / mapposition

##### Start handling #####

