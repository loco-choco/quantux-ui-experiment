class_name ItemInteractCollider extends Area2D

func get_item() -> Item:
	return get_parent() as Item
