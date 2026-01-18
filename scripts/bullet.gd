extends Node2D

@export var speedref := 400.
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func shoot(source : Vector2, target : Vector2) -> void:
	global_position = source
	look_at(target)
	direction = (target - source).normalized()
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible and direction:
		global_position += direction * speedref * delta
