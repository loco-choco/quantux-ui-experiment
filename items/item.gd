extends Area2D

class_name Item

@export var item_name: String = ""
@export var icon: Texture2D

func hide_in_game() -> void:
	hide()
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	
func show_in_game() -> void:
	show()
	set_process_mode(Node.PROCESS_MODE_INHERIT)
