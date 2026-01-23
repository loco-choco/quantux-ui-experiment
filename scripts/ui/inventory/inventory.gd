class_name Inventory extends PanelContainer

signal quick_inventory_update(items: Array[InventoryItem])
signal weapon_slot_update(item: ItemData)
signal side_weapon_slot_update(item: ItemData)
signal item_dropped(item: Item)
signal item_returned(item: Item)

signal potion_used(heal: float)

@export var item_scene: PackedScene
@onready var inventory_item_parent: Control =$%InventoryItems
@export var inventory_item_scene: PackedScene
@onready var inventory_item_popup_parent: Control =$%InventoryItemsPopups
@export var inventory_item_popup_scene: PackedScene

@onready var bag_grid: ItemGrid = $%Bag
@onready var quick_inv_grid: ItemGrid = $%QuickInventory
@onready var shield_slot: InventorySlot = $%ShieldSlot
@onready var weapon_slot: InventorySlot = $%WeaponSlot
@onready var side_weapon_slot: InventorySlot = $%SideWeaponSlot
@onready var drop_item_slot: InventorySlot = $%DropItemSlot

var item_popup : InventoryItemOptionsPopup = null

func _ready() -> void:
	set_as_owner()
	connect_item_slot_updates()
	connect_item_slot_popup()

func set_as_owner() -> void:
	bag_grid.set_inventory_owner(self)
	quick_inv_grid.set_inventory_owner(self)
	shield_slot.inventory_owner = self
	weapon_slot.inventory_owner = self
	side_weapon_slot.inventory_owner = self
	
func hide_ui() -> void:
	hide()
	handle_held_item()
	delete_item_popup()

func connect_item_slot_updates() -> void:
	weapon_slot.item_slot_update.connect(_weapon_slot_update)
	side_weapon_slot.item_slot_update.connect(_side_weapon_slot_update)
	drop_item_slot.item_slot_update.connect(_drop_item_slot_update)
	quick_inv_grid.items_update.connect(_quick_inv_items_update)
	
func connect_item_slot_popup() -> void:
	shield_slot.item_slot_popup.connect(create_item_popup)
	weapon_slot.item_slot_popup.connect(create_item_popup)
	side_weapon_slot.item_slot_popup.connect(create_item_popup)
	bag_grid.item_slot_popup.connect(create_item_popup)
	quick_inv_grid.item_slot_popup.connect(create_item_popup)

func handle_held_item() -> void:
	var held_item : InventoryItem = get_tree().get_first_node_in_group("held_item")
	if held_item:
		var success = bag_grid.attempt_to_add_item_data(held_item)
		if !success:
			_drop_item_slot_update(held_item)

func set_focus() -> void:
	(bag_grid.get_child(0) as Control).grab_focus()


func _weapon_slot_update(item: InventoryItem) -> void:
	if item:
		weapon_slot_update.emit(item.data)
	else:
		weapon_slot_update.emit(null)
		
func _side_weapon_slot_update(item: InventoryItem):
	if item:
		side_weapon_slot_update.emit(item.data)
	else:
		side_weapon_slot_update.emit(null)
	
func _drop_item_slot_update(inv_item: InventoryItem) -> void:
	if inv_item == null:
		return
	drop_item_from_slot(inv_item, drop_item_slot)

func _quick_inv_items_update(items: Array[InventoryItem]) -> void:
	quick_inventory_update.emit(items)


func drop_item_from_slot(inv_item: InventoryItem, slot: InventorySlot) -> void:
	var dropped_item : Item  = item_scene.instantiate()
	dropped_item.item_data = inv_item.data
	inv_item.queue_free()
	slot.clear_item()
	#LogInventory.log_inventory_state("DROP_ITEM: %s" % inv_item.data.name)
	item_dropped.emit(dropped_item)

func add_item(item: Item) -> bool:
	var item_data : ItemData = item.item_data
	var inventory_item : InventoryItem  = inventory_item_scene.instantiate()
	inventory_item.data = item_data
	inventory_item_parent.add_child(inventory_item)
	var success = bag_grid.attempt_to_add_item_data(inventory_item)
	if !success: 
		print("Item doesn't fit!")
		inventory_item.queue_free()
		item_returned.emit(item)
	else:
		item.queue_free()
		#LogInventory.log_inventory_state("ADD_ITEM: %s" % item_data.name)
	return success

func get_bagged_items() -> Array[InventoryItem]:
	return bag_grid.get_items()
	
func get_quick_inv_items() -> Array[InventoryItem]:
	return quick_inv_grid.get_items()

func get_weapon() -> ItemData:
	if weapon_slot.get_item():
		return weapon_slot.get_item().data
	else:
		return null

func create_item_popup(item: InventoryItem) -> void:
	### TODO DECOUPLE THIS FROM INVENTORY
	if item_popup: # Delete old popup
		item_popup.queue_free()
	var item_options : Dictionary[String, Callable] = \
	{"drop": (func(): drop_item_from_slot(item, item.current_slot))}
	var potion_property : PotionItemProperty = item.data.get_property("potion")
	if potion_property:
		item_options["heal"] = (func():_on_potion_used(potion_property.heal_amount, item))
	item_popup = inventory_item_popup_scene.instantiate()
	item_popup.options = item_options
	item_popup.item = item
	item_popup.request_deletion.connect(delete_item_popup)
	inventory_item_popup_parent.add_child(item_popup)

func _on_potion_used(heal_amount: float, item: InventoryItem) -> void:
	potion_used.emit(heal_amount)
	# Remove item from inventory as it was used!
	item.current_slot.clear_item()
	item.queue_free()
	

func delete_item_popup() -> void:
	if !item_popup:
		return
	item_popup.queue_free() # Delete current popup
	item_popup = null
