extends Node2D

@export var speedref := 400.
var direction
var clrCode
var is_big

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func shoot(source : Vector2, target : Vector2, mclrCode : String, big := false) -> void:
	setClr(mclrCode)
	global_position = source
	look_at(target)
	direction = (target - source).normalized()
	visible = true
	if big:
		scale = Vector2(2.5, 2.5)
	else:
		scale = Vector2.ONE
	is_big = big

func setClr(clrLetter : String):
	clrCode = clrLetter
	var index = {"r" : 0, "g" : 1, "b" : 2}[clrLetter]
	var clr = [Vector3(1., 0., 0.), Vector3(0., 1., 0.), Vector3(0., 0.5, 1.)][index]
	$Sprite2D.material.set_shader_parameter("clr", clr)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible and direction:
		global_position += direction * speedref * delta
