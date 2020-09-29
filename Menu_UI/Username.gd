extends Popup

var Firestore_Users: FirestoreCollection
var user_doc:FirestoreDocument

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

var Nicknames:Array
var Nicknames_collection:FirestoreCollection
var Nickname_doc:FirestoreDocument

func _ready():
	var auth = yield(Firebase.Auth,"login_succeeded")
	Nicknames_collection = Firebase.Firestore.collection("Nicknames")
	Nicknames_collection.auth = auth

func _on_Confirm_pressed():
	#print(user_doc.doc_fields)
	#Store old data for deleting nickname and number
	var old_name = user_doc.doc_fields["Username"]
	var new_name = $Panel/VBoxContainer/HBoxContainer/Username.text
	if old_name == new_name:
		return
	var old_number = user_doc.doc_fields["Usernumber"]
	#get current nickname list
	var used_numbers :Array = []
	Firebase.Firestore.list("Nicknames")
	var docs = yield(Firebase.Firestore,"listed_documents")
	for doc in docs["documents"]:
		var docname = doc["name"].rsplit("/",true,1)[1]
		#get document with same name
		if docname == old_name:
			Nicknames_collection.get(docname)
			Nickname_doc = yield(Nicknames_collection,"get_document")
			Nickname_doc.fields2dict(Nickname_doc)
			#check if the number is identical and delete document if true
			if Nickname_doc.doc_fields["Number"] == old_number:
				Nicknames_collection.delete(old_name)
				yield(Nicknames_collection,"delete_document")
		#check if nickname already exitst
		if docname == new_name:
			#get document with same nickname
			Nicknames_collection.get(docname)
			var Nickname_doc = yield(Nicknames_collection,"get_document")
			Nickname_doc.fields2dict(Nickname_doc)
			used_numbers.append(Nickname_doc.doc_fields["Number"])
	#generate number
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var new_number = rng.randi_range(0,1000)
	while used_numbers.has(new_number):
		rng.randomize()
		new_number = rng.randi_range(0,1000)
	user_doc.doc_fields["Username"] = new_name
	user_doc.doc_fields["Usernumber"] = new_number
	Firestore_Users.update(user_doc.doc_name,user_doc.dict2fields(user_doc.doc_fields))
	user_doc = yield(Firestore_Users,"update_document")
	user_doc.doc_name = user_doc.doc_name.rsplit("/",true,1)[1]
	user_doc.fields2dict(user_doc)
	Nickname_doc = FirestoreDocument.new()
	Nicknames_collection.add(new_name,Nickname_doc.dict2fields({"Name": new_name, "Number":new_number}))
	Nickname_doc = yield(Nicknames_collection,"get_document")
	get_parent().user_doc = user_doc
	self.hide()

func _on_Random_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var new_username = randomnames[rng.randi_range(0,randomnames.size())]
	$Panel/VBoxContainer/HBoxContainer/Username.text = new_username
	
