extends Control


func _on_Tooltip_gui_input(event):
	if event is InputEventMouseMotion:
		$Panel.rect_position = event.position

