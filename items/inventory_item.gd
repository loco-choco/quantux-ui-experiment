class_name InventoryItem extends Node2D

@export var data: ItemData = null
var is_rotated: bool = false
@export var is_picked: bool = false
@onready var panel: PanelContainer = $PanelContainer
@onready var icon: TextureRect = $PanelContainer/AspectRatioContainer/Icon

var dimensions: Vector2i:
	get():
		return Vector2i(data.dimensions.y, data.dimensions.x) if is_rotated else data.dimensions

func _ready() -> void:
	if data:
		icon.texture = data.texture

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
			if is_picked:
				do_rotation()

func get_picked_up() -> void:
	add_to_group("held_item")
	is_picked = true
	z_index = 10

func get_placed(rect: Rect2) -> void:
	is_picked = false
	z_index = 0
	global_position = rect.position
	panel.size = rect.size
	remove_from_group("held_item")
	
func do_rotation() -> void:
	var old_size : Vector2 = panel.size / Vector2(dimensions)
	is_rotated = !is_rotated
	panel.size = old_size * Vector2(dimensions)
