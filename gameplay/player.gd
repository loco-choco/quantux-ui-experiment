class_name Player extends Node2D

signal item_collected(item_data: Item)

@export var speed = 200

@onready var inventory : Inventory = $%Inventory
var grabbable_items: Array[Item] = []
@export var dropped_item_offset_radius : float = 25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteBouncer2D.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if InputMode.get_mode() != InputMode.Modes.PLAYER:
		return
	var velocity = Input.get_vector("player_move_x_neg", \
									"player_move_x_pos", \
									"player_move_y_neg", \
									"player_move_y_pos")
	
	global_position += velocity * delta * speed;
	
	if Input.is_action_just_pressed("pickup_item"):
		if grabbable_items.size() > 0:
			var item : Item = grabbable_items.pop_back()
			item.diselect()
			item_collected.emit(item)
				
	# TODO : uncomment this once we have sprites instead of shapes
	#if velocity != Vector2.ZERO:
		#$SpriteBouncer2D.play()
	#else:
		#$SpriteBouncer2D.stop()

func _on_interactable_enter(area: Area2D) -> void:
	var item_coll : ItemInteractCollider = area as ItemInteractCollider
	var item : Item = item_coll.get_item() if item_coll else null
	if item and not grabbable_items.has(item):
		if grabbable_items.size() > 0:
			grabbable_items[-1].diselect()
		grabbable_items.push_back(item)
		item.select()
		
func _on_interactable_exit(area: Area2D) -> void:
	var item_coll : ItemInteractCollider = area as ItemInteractCollider
	var item : Item = item_coll.get_item() if item_coll else null
	if item:
		grabbable_items.erase(item)
		item.diselect()
		if grabbable_items.size() > 0:
			grabbable_items[-1].select()

func _on_inventory_item_dropped(item: Item) -> void:
	item.global_position = global_position + \
			Vector2.RIGHT.rotated(randf()*2*PI) * dropped_item_offset_radius
	if item.get_parent() != get_parent():
		get_parent().add_child(item)
	grabbable_items.push_front(item)
	grabbable_items[-1].select()

func _on_inventory_item_returned(item: Item) -> void:
	grabbable_items.push_front(item)
	grabbable_items[-1].select()
