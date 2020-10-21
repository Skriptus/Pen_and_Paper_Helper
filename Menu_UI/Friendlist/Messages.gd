extends Panel

func _ready():
	yield(get_tree().create_timer(2.0),"timeout")
	var FS = FirebaseStorage.new()
	print("d")
	#FS.download("user://","3y46qyg6swm51.jpg")
