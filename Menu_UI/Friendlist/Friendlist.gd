extends Control

onready var List:VBoxContainer = $Panel/VBoxContainer/ScrollContainer/List
onready var searchbox:VBoxContainer = $Panel/VBoxContainer/Friendsearch
onready var add_friend_b:Button = $Panel/VBoxContainer/VBoxContainer/add_friend
onready var search_line:LineEdit = $Panel/VBoxContainer/Friendsearch/search
onready var search_results:VBoxContainer = $Panel/VBoxContainer/Friendsearch/ScrollContainer/Searchresults
onready var search_result_con:ScrollContainer  = $Panel/VBoxContainer/Friendsearch/ScrollContainer
var user_list

func _on_add_friend_pressed():
	if searchbox.visible:
		searchbox.hide()
		add_friend_b.text = "ADD_FRIEND"
	else:
		searchbox.show()
		add_friend_b.text = "ABORT"
		Collections.update_nicknames()
		user_list = yield(Collections,"list_updated")


func _on_search_text_changed(new_text):
	print(user_list)
	for obj in search_results.get_children():
		search_results.remove_child(obj)
		obj.free()
	for item in user_list:
		var dict = item[item.keys()[0]]
		var found = false
		if new_text in dict["Name"]:
			found = true
		if new_text in String(dict["Number"]):
			found = true
		if new_text in dict["Email"]:
			found = true
		if found:
			var User = preload("res://Menu_UI/Friendlist/Friend.tscn").instance()
			User.name = dict["Name"]
			search_results.add_child(User)
			User.fill(dict["Name"],null)
			search_result_con.rect_size.y = search_results.rect_size.y
	#yield(get_tree().create_timer(1.0), "timeout")
	print(search_results.rect_size.y)
	
