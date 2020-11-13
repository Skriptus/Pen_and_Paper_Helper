extends Control

#onready var List:VBoxContainer = $VBoxContainer/ScrollContainer/List
onready var searchbox:VBoxContainer = $VBoxContainer/Friendsearch
onready var add_friend_b:Button = $VBoxContainer/Con/add_friend
onready var search_line:LineEdit = $VBoxContainer/Friendsearch/search
onready var search_results:VBoxContainer = $VBoxContainer/Friendsearch/ScrollContainer/Searchresults
onready var request:VBoxContainer = $VBoxContainer/Request/ScrollContainer/List
onready var friends:VBoxContainer = $VBoxContainer/Friends/ScrollContainer/List

var parent
var user_list
const max_child_count = 5
const friend_size = 52

signal user_created
signal list_complete

const max_search = 5

func _on_add_friend_pressed():
	if searchbox.visible:
		searchbox.hide()
		add_friend_b.text = "ADD_FRIEND"
	else:
		add_friend_b.text = "ABORT"
		searchbox.show()
		search_line.grab_focus()

func _on_search_text_changed(new_text):
	for item in parent.User_list.keys():
		var item_doc = parent.User_list[item]
		if item_doc["Email"] == parent.email \
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

func Update_list():
	var fields = parent.User_list[parent.email]
	for item in fields["Requestby"]:
		var skip = false
		var usr = parent.User_list[item]
		for child in request.get_children():
			if child.name == parent.User_list[item]["Name"]:
				skip = true
				break
		if skip:
			continue
		new_user(usr,"REQUESTEDBY")
		yield(self,"user_created")
	for item in fields["Requested"]:
		var skip = false
		var usr = parent.User_list[item]
		for child in request.get_children():
			if child.name == parent.User_list[item]["Name"]:
				skip = true
				break
		if skip:
			continue
		new_user(usr,"REQUESTED")
		yield(self,"user_created")
	for item in fields["Friends"]:
		var skip = false
		var usr = parent.User_list[item]
		for child in friends.get_children():
			if child.name == parent.User_list[item]["Name"]:
				skip = true
				break
		if skip:
			continue
		new_user(usr,"FRIENDS")
		yield(self,"user_created")
	emit_signal("list_complete")

func new_user(usr_dict,status,found = "name"):
	var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
	User.name = usr_dict["Name"]
	var req_con:ScrollContainer = request.get_parent()
	var sear_con:ScrollContainer = search_results.get_parent()
	var fri_con:ScrollContainer = friends.get_parent()
	match status:
		"REQUESTEDBY":
			request.add_child(User)
		"REQUESTED":
			request.add_child(User)
		"FOUND":
			search_results.add_child(User)
		"FRIENDS":
			friends.add_child(User)
	if request.get_child_count() >= 1:
		var child_count = request.get_child_count()
		if child_count >= max_child_count:
			child_count = max_child_count
		req_con.rect_min_size.y = child_count * friend_size
	if search_results.get_child_count() >= 1:
		var child_count = search_results.get_child_count()
		if child_count >= max_child_count:
			child_count = max_child_count
		sear_con.rect_min_size.y = child_count * friend_size
	if friends.get_child_count() >= 1:
		var child_count = friends.get_child_count()
		if child_count >= max_child_count:
			child_count = max_child_count
		fri_con.rect_min_size.y = child_count * friend_size	
	User.fill(usr_dict,found)
	User.set_status(usr_dict["Status"])
	emit_signal("user_created")
