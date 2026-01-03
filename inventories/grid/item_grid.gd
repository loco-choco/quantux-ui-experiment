extends GridContainer

const SLOT_SIZE = 16
@export var inventory_slot_scene: PackedScene
@export var dimensions: Vector2i

var slot_data: Array[InventoryItem] = []

func _ready() -> void:
	create_slots()
	init_slot_data()
	
func create_slots() -> void:
	self.columns = dimensions.x
	for y in dimensions.y:
		for x in dimensions.x:
			var inventory_slot = inventory_slot_scene.instantiate()
			add_child(inventory_slot)

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
				
				if !item_fits(index, held_item.data.dimensions):
					return
				
				var items = items_in_area(index, held_item.data.dimensions)
				if items.size() > 1 || index < 0:
					return
				
				if items.size() == 1:
					var item_to_swap_held = items[0]
					item_to_swap_held.get_picked_up()
					remove_item_from_slot_data(item_to_swap_held)
				
				held_item.get_placed(get_slot_coords_from_index(index))
				add_item_to_slot_data(index, held_item)

func init_slot_data() -> void:
	slot_data.resize(dimensions.x * dimensions.y)
	slot_data.fill(null)
	
func get_slot_index_from_coords(coords: Vector2) -> int:
	coords -= self.global_position
	var int_coords = Vector2i(floor(coords / SLOT_SIZE))
	if int_coords.x >= dimensions.x || int_coords.y >= dimensions.y:
		return -1
	var index = int_coords.x + int_coords.y * columns
	if index < 0:
		return -1
	return index
	
func get_slot_coords_from_index(index: int) -> Vector2i:
	return Vector2i(get_child(index).global_position)

func remove_item_from_slot_data(item: InventoryItem) -> void:
	for i in slot_data.size():
		if slot_data[i] == item:
			slot_data[i] = null
			
func add_item_to_slot_data(index: int, item: InventoryItem) -> void:
	for y in item.data.dimensions.y:
		for x in item.data.dimensions.x:
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
		if free_item_space(slot_index, item.data.dimensions):
			break
		slot_index += 1
	if slot_index >= slot_data.size():
		return false
	add_item_to_slot_data(slot_index, item)
	item.set_init_position(get_slot_coords_from_index(slot_index))
	return true
	

func item_fits(index: int, dim: Vector2i) -> bool:
	if index % dimensions.y  + dim.x - 1 >= dimensions.x:
		return false
	@warning_ignore("integer_division")
	if index / dimensions.y + dim.y - 1 >= dimensions.y:
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
