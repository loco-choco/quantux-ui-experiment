class_name ProtectionItemProperty extends ItemProperty

@export var damage_reduction :  float = 0

func get_property_name() -> String:
	return "protection"

func use_property(inventory: Inventory, slot: InventorySlot,\
				  item: InventoryItem) -> void:
	pass
