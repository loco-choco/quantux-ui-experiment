class_name PlayerHUD extends CanvasLayer

signal weapon_slot_update(item: ItemData)
signal side_weapon_slot_update(item: ItemData)
signal item_dropped(item: Item)
signal item_returned(item: Item)

@onready var inventory : Inventory = $%Inventory
@onready var heath_bar : ProgressBar = $%HealthBar
#@onready var quick_inv : RadialInventory = $%QuickInventory

@export var player : Player

func _ready() -> void:
	inventory.hide_ui()
	player.health_changed.connect(_on_player_health_change)
	#quick_inv.hide()
	#quick_inv.menu_closed.connect(_on_quick_inv_closed)
	InputMode.change_mode(InputMode.Modes.PLAYER)
	
#func spriteParam(value, property := "wheelScale") -> void:
	#quick_inv.get_node("MarginContainer/AspectRatioContainer/PanelContainer/Sprite").material.set_shader_parameter(property, value)
	
func _process(_delta: float) -> void:
	if InputMode.get_mode() == InputMode.Modes.MENU:
		return
	#if quick_inv.visible:
		#spriteParam(get_viewport().get_mouse_position() - quick_inv.get_node("MarginContainer/AspectRatioContainer/PanelContainer").global_position - Vector2(120., 120.), "mousePos")
	if Input.is_action_just_pressed("hud_toggle_inventory"):
		#if not quick_inv.visible:
			if not inventory.visible: 
				inventory.show()
				inventory.set_focus()
				InputMode.change_mode(InputMode.Modes.UI)
			else:
				inventory.hide_ui()
				InputMode.change_mode(InputMode.Modes.PLAYER)
	#if Input.is_action_pressed("hud_toggle_quick_inv"):
	#	if not inventory.visible:
	#		if not quick_inv.visible: 
	#			quick_inv.show()
	#			create_tween().tween_method(spriteParam, 1.6, 1.1, 0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	#else:
	#	quick_inv.hide()

#func _on_quick_inv_closed() -> void:
	#quick_inv.hide()

func _on_player_health_change(value: float) -> void:
	create_tween().tween_method((func(v: float): heath_bar.value = v),\
	 heath_bar.value, value, 0.5).set_ease(Tween.EASE_OUT)
	
func _on_player_item_collected(item: Item) -> void:
	inventory.add_item(item)

func _on_inventory_item_dropped(item: Item) -> void:
	item_dropped.emit(item)

func _on_inventory_item_returned(item: Item) -> void:
	item_returned.emit(item)

func _on_inventory_weapon_slot_update(item: ItemData) -> void:
	weapon_slot_update.emit(item)
	
func _on_inventory_side_weapon_slot_update(item: ItemData) -> void:
	side_weapon_slot_update.emit(item)
