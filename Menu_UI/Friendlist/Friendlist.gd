extends Control

onready var List:VBoxContainer = $VBoxContainer/ScrollContainer/List
onready var searchbox:VBoxContainer = $VBoxContainer/Friendsearch
onready var add_friend_b:Button = $VBoxContainer/Con/add_friend
onready var search_line:LineEdit = $VBoxContainer/Friendsearch/search
onready var search_results:VBoxContainer = $VBoxContainer/Friendsearch/ScrollContainer/Searchresults
onready var search_result_con:ScrollContainer  = $VBoxContainer/Friendsearch/ScrollContainer
onready var request:VBoxContainer = $VBoxContainer/Request/ScrollContainer/List
onready var request_con:VBoxContainer = $VBoxContainer/Request

var user_list

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
			var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
			User.name = dict["Name"]
			search_results.add_child(User)
			User.fill(dict,found)
			search_result_con.rect_size.y = search_results.rect_size.y
	var child_count = search_results.get_child_count()
	if child_count >= 5:
		child_count = 5
	search_result_con.rect_min_size = Vector2(250,30*child_count)
