class_name Item extends Node2D

@export var item_data: ItemData
@onready var icon: TextureRect = $%Icon
@onready var diselected: Control = $%Diselected
@onready var selected: Control = $%Selected

@onready var item_collider: Area2D = $%ItemCollider
@export var item_force_field_accel : float = 10

func _ready() -> void:
	sync_with_item_data()
	diselect()

func _physics_process(delta: float) -> void:
	var accel : Vector2 = Vector2.ZERO
	for area : Area2D in item_collider.get_overlapping_areas():
		accel = accel + \
			  (global_position - area.global_position) * item_force_field_accel
	global_position = global_position + accel * delta

func sync_with_item_data() -> void:
	icon.texture = item_data.texture

func diselect() -> void:
	diselected.show()
	selected.hide()
	
func select() -> void:
	diselected.hide()
	selected.show()
