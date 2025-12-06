extends Area2D

signal item_collected(item: Item)

@export var speed = 200
var screen_size

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
	position += velocity.normalized() * delta * speed;
	
	if velocity != Vector2.ZERO:
		$SpriteBouncer2D.play()
	else:
		$SpriteBouncer2D.stop()

func _on_area_entered(area: Area2D) -> void:
	if area is Item:
		print("Item!")
		item_collected.emit(area as Item)
