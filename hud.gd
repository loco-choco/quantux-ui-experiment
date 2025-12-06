extends CanvasLayer

func _ready() -> void:
	$Inventory.hide()
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hud_toggle_inventory"):
		if not $Inventory.visible: 
			$Inventory.show()
		else:
			$Inventory.hide()

func _on_player_item_collected(item: Item) -> void:
	$Inventory.add_item(item)
