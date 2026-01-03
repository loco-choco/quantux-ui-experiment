class_name InventoryItem extends Node2D

const ITEM_SIZE = 16

var data: ItemData = null
var is_picked: bool = false
@onready var panel: PanelContainer = $PanelContainer
@onready var icon: TextureRect = $PanelContainer/Icon

var size: Vector2:
	get():
		return Vector2(data.dimensions.x, data.dimensions.y) * ITEM_SIZE
		
var upper_corner: Vector2:
	get():
		return global_position + panel.pivot_offset - size / 2

func _ready() -> void:
	if data:
		icon.texture = data.texture
		panel.size = data.dimensions * ITEM_SIZE
		panel.pivot_offset = data.dimensions * ITEM_SIZE / 2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT && event.is_pressed():
			if is_picked:
				do_rotation()

func _process(_delta: float) -> void:
	if is_picked:
		global_position = get_global_mouse_position() - panel.pivot_offset 
		
func set_init_position(pos: Vector2) -> void:
	global_position = pos
	
func get_picked_up() -> void:
	add_to_group("held_item")
	is_picked = true
	z_index = 10

func get_placed(pos: Vector2) -> void:
	is_picked = false
	z_index = 0
	global_position = pos - (panel.pivot_offset - size / 2)
	remove_from_group("held_item")
	
func do_rotation() -> void:
	data.is_rotated = !data.is_rotated
	data.dimensions = Vector2i(data.dimensions.y, data.dimensions.x)
	var tween = create_tween()
	tween.tween_property(panel, "rotation_degrees", 90 if data.is_rotated else 0, 0.3)
