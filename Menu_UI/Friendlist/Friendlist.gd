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

var parent

var user_list

signal user_created
signal list_complete

func _on_add_friend_pressed():
	if searchbox.visible:
		searchbox.hide()
		add_friend_b.text = "ADD_FRIEND"
	else:
		add_friend_b.text = "ABORT"
		searchbox.show()
		search_line.grab_focus()

func _on_search_text_changed(new_text):
	for obj in search_results.get_children():
		search_results.remove_child(obj)
		obj.free()
	for item in parent.User_list:
		var item_doc = parent.User_list[item]
		if item == parent.email \
		or item_doc["Friends"].has(parent.email) \
		or item_doc["Blockedby"].has(parent.email) \
		or item_doc["Blocked"].has(parent.email) \
		or item_doc["Requestby"].has(parent.email) \
		or item_doc["Requested"].has(parent.email):
			continue
		var found = null
		if new_text in item_doc["Name"]:
			found = "name"
		if new_text in String(item_doc["Number"]):
			found = "number"
		if new_text in item_doc["Email"]:
			found = "email"
		if found:
			new_user(item_doc,"FOUND",found)
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
	var fields = parent.User_doc
	for item in fields["Requestby"]:
		var usr = parent.User_list[item]
		new_user(usr,"REQUESTEDBY")
		yield(self,"user_created")
	for item in fields["Requested"]:
		var usr = parent.User_list[item]
		new_user(usr,"REQUESTED")
		yield(self,"user_created")
	for item in fields["Friends"]:
		var usr = parent.User_list[item]
		new_user(usr,"FRIENDS")
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

func new_user(usr_dict,status,found = "name"):
	var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
	User.name = usr_dict["Name"]
	match status:
		"REQUESTEDBY":
			request.add_child(User)
		"REQUESTED":
			request.add_child(User)
		"FOUND":
			search_results.add_child(User)
		"FRIENDS":
			Friends.add_child(User)
	User.fill(usr_dict,found)
	User.set_status(status)
	emit_signal("user_created")
