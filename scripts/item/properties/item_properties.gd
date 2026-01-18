@abstract
class_name ItemProperty extends Resource

@abstract
func get_property_name() -> String

@abstract
func use_property(_inventory: Inventory, _slot: InventorySlot,\
				  _item: InventoryItem) -> void
	
