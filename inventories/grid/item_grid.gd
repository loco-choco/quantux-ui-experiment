class_name ItemGrid extends Control

@export var inventory_slot_scene: PackedScene
@export var rows : int = 1
@export var columns : int = 1

@onready var grid : MatrixContainer = $Grid

func _ready() -> void:
	grid.rows = rows
	grid.columns = columns
	create_slots()

func create_slots() -> void:
	var slots: Array[InventorySlot] = []
	for y in rows:
		for x in columns:
			var inventory_slot : InventorySlot = inventory_slot_scene.instantiate()
			grid.add_child(inventory_slot)
			slots.push_back(inventory_slot)
	for y in rows:
		for x in columns:
			var slot : InventorySlot = slots[x + y * rows]
			slot.top_neighbor    = slots[x + (y - 1) * rows] if y > 0           else null
			slot.bottom_neighbor = slots[x + (y + 1) * rows] if y < rows - 1    else null
			slot.right_neighbor  = slots[x + 1 + y * rows]   if x < columns - 1 else null
			slot.left_neighbor   = slots[x - 1 + y * rows]   if x > 0           else null
			slot.set_neighbors_as_next_on_focus()

func attempt_to_add_item_data(item: InventoryItem) -> bool:
	for s : InventorySlot in grid.get_children():
			if s.set_item(item):
				var item_rect : Rect2 = Rect2(s.global_position, \
											  s.size * Vector2(item.dimensions))
				item.get_placed(item_rect)
				return true
	return false
