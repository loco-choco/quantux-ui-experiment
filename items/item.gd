class_name Item extends Area2D

@export var item_data: ItemData
@onready var sprite: SpriteBouncer2D = $SpriteBouncer2D

func _ready() -> void:
	sync_with_item_data()

func sync_with_item_data() -> void:
	sprite.texture = item_data.texture

func hide_in_game() -> void:
	hide()
	set_process_mode(Node.PROCESS_MODE_DISABLED)
	
func show_in_game() -> void:
	show()
	set_process_mode(Node.PROCESS_MODE_INHERIT)
