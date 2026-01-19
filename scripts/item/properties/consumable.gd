class_name ConsumableItemProperty extends ItemProperty

@export var amount :  int = 0

func consume() -> void:
	if amount <= 0:
		return
	amount = amount - 1
	print("consumed! now: ", amount)
	# TODO Execute Consumable Code Here

func get_property_name() -> String:
	return "consumable"
