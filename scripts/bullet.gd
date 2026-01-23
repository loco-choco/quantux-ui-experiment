class_name Bullet extends Area2D

@export var speedref := 400.
@export var target : Vector2
var direction : Vector2
@export var color_code : String
@export var is_big : bool = false
@export var base_damage : float = 25

@export var bullet_owner : Area2D
@export var distance_until_despawn : float = 1000


@onready var visual : ColorRect = $%Visual

var color_dict : Dictionary[String, Color] = {"r" : Color.RED, "g" : Color.GREEN, "b" : Color.BLUE}

func _ready() -> void:
	setClr()
	look_at(target)
	direction = (target - global_position).normalized()
	if is_big:
		scale = Vector2(2.5, 2.5)
	else:
		scale = Vector2.ONE

func setClr() -> void:
	var clr : Color = color_dict[color_code]
	visual.color = clr

func _process(delta: float) -> void:
	if direction:
		global_position += direction * speedref * delta
	if (global_position - bullet_owner.global_position).length_squared() >= distance_until_despawn**2:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area == bullet_owner:
		return
	if not area.get_parent() or not area.get_parent() is Enemy:
		return
	var enemy : Enemy = area.get_parent() as Enemy
	var damage : float = base_damage * 2 if is_big else base_damage
	enemy.take_damage(damage, color_code)
	queue_free()
