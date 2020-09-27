extends Node

class_name character

##### General Info #####

var character_name:String
onready var character_race:Object = $Race
onready var character_class:Object = $Class
onready var character_sex:Object = $Sex
var character_age:int


##### Advanced Info #####

onready var character_inventory:Object = $Inventory
onready var character_stats:Object = $Stats


##### Base stats #####
var health:int = 0
var energy:int = 0
var karma:int = 0
var strength:int = 0
var agility:int = 0
var resistance:int = 0
var perception:int = 0
var intelligence:int = 0
var wisdom:int = 0
var aura:int = 0
var faith:int = 0
var ego:int = 0

##### Physical attacks #####
var attack:int = 0
var parade:int = 0

var singlehanded:int = 0
var twohanded:int = 0
var staffweapons:int = 0
var distance:int = 0

var single_sword:int = 0
var single_hammer:int = 0
var single_axe:int = 0

var two_sword:int = 0
var two_hammer:int = 0
var two_axe:int = 0

var staff_spear:int = 0
var staff_morningstar:int = 0
var staff_gleave:int = 0

var dist_bow:int = 0
var dist_crossbow:int = 0

##### Magical attacks #####

var astralenergy:int = 0
var astralkoncentration:int = 0

var elements:int = 0
var energyweapons:int = 0
var summon:int = 0

var el_fire:int = 0
var el_water:int = 0
var el_air:int = 0
var el_earth:int = 0

var en_light:int = 0
var en_dark:int = 0

var sum_animal:int = 0
var sum_ghost:int = 0
var sum_zombie:int = 0

##### Game stats #####

var allies:Array = []
var enemies:Array = []
var player:Object
var position:Array = [[0,0],[0,0]] #overworldpostiotion / mapposition

var prayers_today:int = 0


##### Start handling #####

func _ready():
	character_race.player_pharacter = self
