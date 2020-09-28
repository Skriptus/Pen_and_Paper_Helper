extends Popup


var Nicknames:Array
var FC

func _ready():
	var auth = yield(Firebase.Auth,"login_succeeded")
	FC = Firebase.Firestore.collection("Nicknames")
	FC.auth = auth

func _on_Confirm_pressed():
	pass # Replace with function body.


func _on_Random_pressed():
	pass # Replace with function body.
	

func _on_Username_focus_entered():
	Firebase.Firestore.list("Nicknames")
	var docs = yield(Firebase.Firestore,"listed_documents")
	for doc in docs["documents"]:
		var docname = doc["name"].rsplit("/",true,1)[1]
		FC.get(docname)
		var nick_doc = yield(FC,"get_document")
		var dict = nick_doc.fields2dict(nick_doc)
		Nicknames.append(dict)
	
