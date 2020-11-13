extends Popup

signal new_username(username)

var randomnames = ["palatablediamonds",
	"epeeattention",
	"chokeartificial",
	"morganathranduil",
	"spankernancy",
	"mistakequestion",
	"amuckmoneybag",
	"patienceelegant",
	"releaseargybargy",
	"pitchervacuous",
	"uneasepossessive",
	"squatreflect",
	"boingbombadil",
	"realtordefinite",
	"batoninfluence",
	"smashpartridge",
	"stainmaniacal",
	"ubiquityfinical",
	"findgush",
	"cohortspoke",
	"professequestrian",
	"latesiege",
	"vshystertidy",
	"nucleusworst",
	"croquetpreacher",
	"guillemotindian",
	"achoopsychotic",
	"squigglyultimate",
	"ampleemergency",
	"antiquecriticize",
	"spancomment",
	"loutishuntidy",
	"prickmighty",
	"longjumpgymnasium",
	"trusteesandals",
	"fumblingfumbling",
	"rubeustell",
	"poisedcarve",
	"cauldronlimb",
	"coherentpatsy",
	"insurancepolevault",
	"javelinnext",
	"ratlinedraggle",
	"vthouibis",
	"lamentcurator",
	"anxiousanus",
	"lipstickabusive",
	"explainmordor",
	"mandiblecycle",
	"possessiongaseous",
	"vsafezing",
	"vmainstaynauseating",
	"unawaremoldy",
	"savagerycaluminous",
	"fatherlyembarrass",
	"bowlerdoves",
	"acidicobservant",
	"muesliungentle",
	"unequaledcrushing",
	"wingardiumunited",
	"martendrafty",
	"kettleunderstand",
	"hauntinganalyst",
	"cofflerepair",
	"depressedfailing",
	"differentcheery",
	"racingscoreboard",
	"totalalarming",
	"protectionhastiness",
	"economyexciting",
	"keepunicycle",
	"simplicitycurl",
	"roachjoiner",
	"testedforesail",
	"armtaxidriver",
	"forbiddencable",
	"attentionlouse",
	"turkishdespairing",
	"farenormous",
	"shenaniganstorm",
	"factorychurlish",
	"becomeblackening",
	"projectorfee",
	"polarbearpitch",
	"hoddypeakracer",
	"atmpallograph",
	"shapelessunthinking",
	"guaranteeboggart",
	"awarenessagitated",
	"speculatenavel",
	"roedeersmiley",
	"doubtfulhornbill",
	"droopysuppose",
	"coffinshrouds",
	"increaserural",
	"picklecold",
	"spoonemigrate",
	"brouhahapotato",
	"liberatedfather",
	"ourgrand",
	"plowbounce",
	"mutedfume",
	"gulpabsorbed",
	"boomerangwayward",
	"greyspades",
	"bikeunknown",
	"ribbitemotion",
	"forefingeronlooker",
	"offensenun",
	"catererhidden",
	"occiputmoor",
	"sillynescafe",
	"bosnianpry",
	"fastenstarbolins",
	"kayakingimpartial",
	"leechsand",
	"owlerybother",
	"nullillogical",
	"tremendousfeeble",
	"zestysorner",
	"bankerepileptic",
	"instructjumpy",
	"elatedenedwaith",
	"weedyirritated",
	"ashamedpurse",
	"reveredtweezers",
	"unbiasedrhyme",
	"medicalvaulter",
	"fiddleyrubbish",
	"customsrepulsive",
	"actorprotest",
	"cofferdamonion",
	"motorboatmole",
	"raccoondimwitted",
	"nextremain",
	"sordidimplement",
	"elasticvanquish",
	"committeerepel",
	"stackboundless",
	"blushaustrian",
	"jowlbarnacle",
	"reachunripe",
	"homerunsplash",
	"slimyhootenanny",
	"walkpoof",
	"sanguineseason",
	"precedecroquet",
	"rinsesynonymous",
	"panjandrumcartilage",
	"quizprofuse",
	"abaloneminor",
	"zealjealous",
	"tykescribble",
	"veneratedsupplies",
	"billiardsswimming",
	"swooshdrone",
	"vacantrat",
	"restaurantbombur",
	"sufferglad",
	"cadgeautomatic",
	"silentwinning",
	"lateenconvert",
	"doteinfectious",
	"zwodderhate",
	"pharmacistostrich",
	"postboxlackluster",
	"soothsayerriding",
	"purserdeceive",
	"movecocktail",
	"lavabung",
	"cowardiranian",
	"bobsleighcorps",
	"bulkycullionly",
	"anybodysubway",
	"mostafapurr",
	"abstractedjoyful",
	"boinkyoke",
	"knotwitty",
	"starkaccepting",
	"princefrighten",
	"sitrustle",
	"skilltask",
	"scenepossible",
	"yardarmrevolution",
	"burnishmakeshift",
	"joystickkayaking",
	"graciouspointed",
	"bassstarchy",
	"noticecandidate",
	"electionjaded",
	"siegeyielding",
	"shrimputopian",
	"strangelyroband",
	"wombathotdog",
	"abilitybeginner",
	"resolutiondrove",
	"tenuouscuckold",
	"hooliganguess",
	"saultopen",
	"labourershotput"]

var allow_close:= false
onready var NameLine:LineEdit = $Panel/VBoxContainer/HBoxContainer/Username
onready var Notification = $Panel/VBoxContainer/Notification

func _on_Confirm_pressed():
	if Badwords._check_word(NameLine.text):
		if NameLine.text:
			emit_signal("new_username",NameLine.text)
			Notification.hide()
			NameLine.text = ""
			self.hide()
		else:
			Notification.text = "NO_USERNAME_ENTERD"
			Notification.show()
	else:
		Notification.text = "BADWORD_ENTERD"
		Notification.show()

func _on_Random_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var new_username = randomnames[rng.randi_range(0,randomnames.size())]
	NameLine.text = new_username

func _on_Close_pressed():
	if allow_close:
		NameLine.text = ""
		Notification.hide()
		self.hide()
	else:
		Notification.text = "NO_USERNAME_SET"
		Notification.show()
