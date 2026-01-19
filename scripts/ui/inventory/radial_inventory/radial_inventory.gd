class_name RadialInventory extends PanelContainer

@export var radial_inv_entry : PackedScene

@onready var entries : Container = $%Entries



func clean_entries() -> void:
	for c in entries.get_children():
		c.queue_free()

func create_entries(items: Array[InventoryItem]) -> void:
	for item in items:
		var entry : RadialInventoryEntry = radial_inv_entry.instantiate()
		entry.item = item
		entries.add_child(entry)
