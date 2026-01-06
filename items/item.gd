extends Area2D

class_name Item

@export var item_data: ItemData

func hide_in_game() -> void:
	hide()
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	
func show_in_game() -> void:
	show()
	set_process_mode(Node.PROCESS_MODE_INHERIT)
