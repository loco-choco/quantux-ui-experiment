class_name ItemGrid extends MatrixContainer

@export var inventory_slot_scene: PackedScene

var SLOT_SIZE : float

func _ready() -> void:
	create_slots()
	init_slot_data()
	
func create_slots() -> void:
	var slots: Array[InventorySlot] = []
	for y in rows:
		for x in columns:
			var inventory_slot : InventorySlot = inventory_slot_scene.instantiate()
			add_child(inventory_slot)
			slots.push_back(inventory_slot)
	for y in rows:
		for x in columns:
			var slot : InventorySlot = slots[x + y * rows]
			slot.top_neighbor    = slots[x + (y - 1) * rows] if y > 0           else null
			slot.bottom_neighbor = slots[x + (y + 1) * rows] if y < rows - 1    else null
			slot.right_neighbor  = slots[x + 1 + y * rows]   if x < columns - 1 else null
			slot.left_neighbor   = slots[x - 1 + y * rows]   if x > 0           else null
	
	SLOT_SIZE = (get_child(0)  as Control).size.x

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			var held_item = get_tree().get_first_node_in_group("held_item") as InventoryItem
			if !held_item:
				var slot_index = get_slot_index_from_coords(get_global_mouse_position())
				if slot_index < 0:
					return
				var item = slot_data[slot_index]
				if !item:
					return
				item.get_picked_up()
				remove_item_from_slot_data(item)
			else:
				var offset = Vector2.ONE * SLOT_SIZE / 2
				var index = get_slot_index_from_coords(held_item.upper_corner + offset)
				
				if !item_fits(index, held_item.dimensions):
					return
				
				var items = items_in_area(index, held_item.dimensions)
				if items.size() > 1 || index < 0:
					return
				
				if items.size() == 1:
					var item_to_swap_held = items[0]
					item_to_swap_held.get_picked_up()
					remove_item_from_slot_data(item_to_swap_held)
				
				held_item.get_placed(get_slot_coords_from_index(index))
				add_item_to_slot_data(index, held_item)


func remove_item_from_slot_data(item: InventoryItem) -> void:
	for i in slot_data.size():
		if slot_data[i] == item:
			slot_data[i] = null
			
func add_item_to_slot_data(index: int, item: InventoryItem) -> void:
	for y in item.dimensions.y:
		for x in item.dimensions.x:
			slot_data[index + x + y * columns] = item 


func items_in_area(index: int, dim: Vector2i) -> Array[InventoryItem]:
	var items: Array[InventoryItem] = []
	for y in dim.y:
		for x in dim.x:
			var item = slot_data[index + x + y * columns]
			if !item:
				continue
			if !items.has(item):
				items.append(item)
	return items
	

func attempt_to_add_item_data(item: InventoryItem) -> bool:
	var slot_index: int = 0
	while slot_index < slot_data.size():
		if free_item_space(slot_index, item.dimensions):
			break
		slot_index += 1
	if slot_index >= slot_data.size():
		return false
	add_item_to_slot_data(slot_index, item)
	item.set_init_position(get_slot_coords_from_index(slot_index))
	return true
	

func item_fits(index: int, dim: Vector2i) -> bool:
	if index % columns + dim.x - 1 >= rows:
		return false
	@warning_ignore("integer_division")
	if index / columns + dim.y - 1 >= columns:
		return false
	return true
	
func free_item_space(index: int, dim: Vector2i) -> bool:
	for y in dim.y:
		for x in dim.x:
			var curr_index = index + x + y * columns
			if curr_index >= slot_data.size():
				return false
			if slot_data[curr_index] != null:
				return false
			@warning_ignore("integer_division")
			var split = index / columns != (index + x) / columns
			if split:
				return false
	return true
