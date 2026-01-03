class_name InventoryItem extends Sprite2D

const ITEM_SIZE = 16

var data: ItemData = null
var is_picked: bool = false

var size: Vector2:
	get():
		return Vector2(data.dimensions.x, data.dimensions.y) * ITEM_SIZE
		
var upper_corner: Vector2:
	get():
		return global_position - size / 2

func _ready() -> void:
	#offset = - size / 2
	if data:
		texture = data.texture

func _process(_delta: float) -> void:
	if is_picked:
		global_position = get_global_mouse_position()
		
func set_init_position(pos: Vector2i) -> void:
	global_position = pos + Vector2i(size / 2)
	
func get_picked_up() -> void:
	add_to_group("held_item")
	is_picked = true
	z_index = 10

func get_placed(pos: Vector2i) -> void:
	is_picked = false
	z_index = 0
	global_position = pos + Vector2i(size / 2)
	remove_from_group("held_item")
