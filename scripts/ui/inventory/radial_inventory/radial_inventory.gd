class_name RadialInventory extends PanelContainer

signal menu_closed()

@export var radial_inv_entry : PackedScene

@onready var entries : Container = $%Entries

func _process(_delta: float) -> void:
	var selection_vec: Vector2 = (get_local_mouse_position() - size/2 ).normalized()
	if selection_vec.is_zero_approx():
		return
	var selection: int = floori(rad_to_deg(selection_vec.angle() + PI) / 360 \
						 * entries.get_child_count()) % entries.get_child_count()
	if Input.is_action_just_pressed("item_use"):
		print("Selected: ", selection)
		menu_closed.emit()

func update_radial_inventory(items: Array[InventoryItem]) -> void:
	clean_entries()
	create_entries(items)

func clean_entries() -> void:
	for c in entries.get_children():
		c.queue_free()

func create_entries(items: Array[InventoryItem]) -> void:
	for item in items:
		var entry : RadialInventoryEntry = radial_inv_entry.instantiate()
		entry.item = item
		entries.add_child(entry)
