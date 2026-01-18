class_name DroppableItemProperty extends ItemProperty

func use_property(inventory: Inventory, slot: InventorySlot,\
				  item: InventoryItem) -> void:
	inventory.drop_item_from_slot(item, slot)
