extends Sprite2D

@export var limit = 7
@export var speed = 60
var direction
var looping
var frozen

func Play() -> void:
	looping = true
	frozen = false
	
func Stop() -> void:
	looping = false
	
func Freeze() -> void:
	frozen = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = 1
	looping = true
	frozen = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frozen:
		pass
	var angle = rotation_degrees
	angle += speed * direction * delta
	if (abs(angle) >= limit):
		angle = limit * direction
		direction = -direction
	if (!looping && sign(angle) != sign(rotation_degrees)):
		angle = 0
	rotation_degrees = angle
