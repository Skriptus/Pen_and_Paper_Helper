extends Control

#onready var List:VBoxContainer = $VBoxContainer/ScrollContainer/List
onready var searchbox:VBoxContainer = $VBoxContainer/Friendsearch
onready var add_friend_b:Button = $VBoxContainer/Con/add_friend
onready var search_line:LineEdit = $VBoxContainer/Friendsearch/search
onready var search_results:VBoxContainer = $VBoxContainer/Friendsearch/ScrollContainer/Searchresults
onready var search_result_con:ScrollContainer  = $VBoxContainer/Friendsearch/ScrollContainer
onready var request:VBoxContainer = $VBoxContainer/Request/ScrollContainer/List
onready var request_con:ScrollContainer = $VBoxContainer/Request/ScrollContainer
onready var Friends:VBoxContainer = $VBoxContainer/Friends/ScrollContainer/List
onready var Friends_con = $VBoxContainer/Friends/ScrollContainer

var user_list

signal user_created
signal list_complete

func _on_add_friend_pressed():
	if searchbox.visible:
		searchbox.hide()
		add_friend_b.text = "ADD_FRIEND"
	else:
		add_friend_b.text = "ABORT"
		Collections.update_nicknames()
		user_list = yield(Collections,"list_updated")
		searchbox.show()
		search_line.grab_focus()

func _on_search_text_changed(new_text):
	for obj in search_results.get_children():
		search_results.remove_child(obj)
		obj.free()
	for item in user_list:
		var item_email = item.keys()[0]
		var doc_fields = Network.parent.User_doc.doc_fields
		if item_email == Network.parent.email \
		or doc_fields["Friends"].has(item_email) \
		or doc_fields["Blockedby"].has(item_email) \
		or doc_fields["Blocked"].has(item_email) \
		or doc_fields["Requestby"].has(item_email) \
		or doc_fields["Requested"].has(item_email):
			continue
		var dict = item[item_email]
		var found = null
		if new_text in dict["Name"]:
			found = "name"
		if new_text in String(dict["Number"]):
			found = "number"
		if new_text in dict["Email"]:
			found = "email"
		if found:
			new_user(dict["Name"],dict,"FOUND",found)
	var child_count = search_results.get_child_count()
	if child_count >= 5:
		child_count = 5
	search_result_con.rect_min_size = Vector2(250,60*child_count)

func Update_list():
	for obj in Friends.get_children():
		Friends.remove_child(obj)
		obj.free()
	for obj in request.get_children():
		Friends.remove_child(obj)
		obj.free()
	var fields = Network.parent.User_doc.doc_fields
	for item in fields["Requestby"]:
		Collections.get_nickname(item)
		var usr_dict = yield(Collections,"got_nickname")
		new_user(usr_dict.doc_fields["Name"],usr_dict.doc_fields,"REQUESTEDBY")
		yield(self,"user_created")
	for item in fields["Requested"]:
		Collections.get_nickname(item)
		var usr_dict = yield(Collections,"got_nickname")
		new_user(usr_dict.doc_fields["Name"],usr_dict.doc_fields,"REQUESTED")
		yield(self,"user_created")
	for item in fields["Friends"]:
		Collections.get_nickname(item)
		var usr_dict = yield(Collections,"got_nickname")
		new_user(usr_dict.doc_fields["Name"],usr_dict.doc_fields,"FRIENDS")
		yield(self,"user_created")
	if request.get_child_count() > 0:
		request_con.show()
		request_con.rect_min_size = Vector2(250,60*request.get_child_count())
	else:
		request_con.hide()
	if Friends.get_child_count() > 0:
		Friends_con.show()
		Friends_con.rect_min_size = Vector2(250,60*Friends.get_child_count())
	else:
		Friends_con.hide()
	emit_signal("list_complete")

func new_user(Name,usr_dict,status,found = "name"):
	var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
	User.name = Name
	match status:
		"REQUESTEDBY":
			request.add_child(User)
		"REQUESTED":
			request.add_child(User)
		"FOUND":
			search_results.add_child(User)
		"FRIENDS":
			Collections.get_user(usr_dict["Email"])
			var usr = yield(Collections,"got_user")
			Friends.add_child(User)
			status = usr.doc_fields["Status"]
	User.fill(usr_dict,found)
	User.set_status(status)
	emit_signal("user_created")
