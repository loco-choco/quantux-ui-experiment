extends Control

func _on_player_item_collected(item: Item) -> void:
	print("Collecting item!")
	$Inventory.add_item(item)
