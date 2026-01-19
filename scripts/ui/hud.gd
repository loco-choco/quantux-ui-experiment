extends CanvasLayer
@onready var inventory : Inventory = $%Inventory
@onready var quick_inv : RadialInventory = $%QuickInventory
func _ready() -> void:
	inventory.hide_ui()
	quick_inv.hide()
	InputMode.change_mode(InputMode.Modes.PLAYER)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("hud_toggle_inventory"):
		if not quick_inv.visible:
			if not inventory.visible: 
				inventory.show()
				inventory.set_focus()
				InputMode.change_mode(InputMode.Modes.UI)
			else:
				inventory.hide_ui()
				InputMode.change_mode(InputMode.Modes.PLAYER)
	if Input.is_action_just_pressed("hud_toggle_quick_inv"):
		if not inventory.visible:
			if not quick_inv.visible: 
				quick_inv.show()
			else:
				quick_inv.hide()

func _on_player_item_collected(item: Item) -> void:
	inventory.add_item(item)
