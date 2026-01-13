class_name Player extends Area2D

signal item_collected(item_data: Item)

@export var speed = 200

@onready var inventory : Inventory = $%Inventory
var selected_ground_item : Item = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteBouncer2D.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("player_move_x_pos"):
		velocity.x += 1
	if Input.is_action_pressed("player_move_x_neg"):
		velocity.x -= 1
	if Input.is_action_pressed("player_move_y_pos"):
		velocity.y += 1
	if Input.is_action_pressed("player_move_y_neg"):
		velocity.y -= 1
	global_position += velocity.normalized() * delta * speed;
	
	if Input.is_action_just_pressed("pickup_item"):
		if selected_ground_item:
			item_collected.emit(selected_ground_item)
				
	# TODO : uncomment this once we have sprites instead of shapes
	#if velocity != Vector2.ZERO:
		#$SpriteBouncer2D.play()
	#else:
		#$SpriteBouncer2D.stop()

func _on_area_entered(area: Area2D) -> void:
	var item : Item = area as Item
	if item:
		if selected_ground_item:
			selected_ground_item.diselect()
		selected_ground_item = item
		selected_ground_item.select()
		
func _on_area_exited(area: Area2D) -> void:
	var item : Item = area as Item
	if item:
		if selected_ground_item == item:
			selected_ground_item = null
		item.diselect()


func _on_inventory_item_dropped(item: Item) -> void:
	item.global_position = global_position
	get_parent().add_child(item)
