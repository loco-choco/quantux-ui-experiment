extends Area2D


@export var speed = 200
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SpriteBouncer2D.Stop()


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
	position += velocity * delta * speed;
	
	if velocity != Vector2.ZERO:
		$SpriteBouncer2D.Play()
	else:
		$SpriteBouncer2D.Stop()
