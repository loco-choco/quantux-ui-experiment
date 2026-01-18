class_name DroppableItemProperty extends ItemProperty

func get_property_name() -> String:
	return "droppable"

func use_property(inventory: Inventory, slot: InventorySlot,\
				  item: InventoryItem) -> void:
	inventory.drop_item_from_slot(item, slot)
