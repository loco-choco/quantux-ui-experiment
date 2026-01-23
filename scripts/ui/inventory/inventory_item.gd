class_name InventoryItem extends Node2D

@export var data: ItemData = null
var is_rotated: bool = false

@export var is_picked: bool = false
@export var picked_pos: Vector2i = Vector2i.ZERO

@onready var panel: PanelContainer = $%Item
@onready var icon: TextureRect = $%Icon

@onready var diselected: Control = $%Diselected
@onready var selected: Control = $%Selected
@onready var held: Control = $%Held

var current_slot: InventorySlot = null

var dimensions: Vector2i:
	get():
		return Vector2i(data.dimensions.y, data.dimensions.x) if is_rotated \
			   else data.dimensions

func _ready() -> void:
	show_unfocus()
	if data:
		icon.texture = data.texture

func get_picked_up(pos: Vector2i = Vector2i.ZERO) -> void:
	add_to_group("held_item")
	show_held()
	is_picked = true
	picked_pos = pos
	current_slot = null
	z_index = 10

func update_size(rect: Rect2) -> void:
	global_position = rect.position
	panel.size = rect.size
	
func get_placed(rect: Rect2, slot: InventorySlot) -> void:
	update_size(rect)
	remove_from_group("held_item")
	is_picked = false
	picked_pos = Vector2.ZERO
	current_slot = slot
	z_index = 0
	
func show_focus() -> void:
	held.hide()
	diselected.hide()
	selected.show()
	
func show_unfocus() -> void:
	held.hide()
	diselected.show()
	selected.hide()
	
func show_held() -> void:
	held.show()
	diselected.hide()
	selected.hide()
	
func do_rotation() -> void:
	is_rotated = !is_rotated
	picked_pos = Vector2i(picked_pos.y, picked_pos.x)
