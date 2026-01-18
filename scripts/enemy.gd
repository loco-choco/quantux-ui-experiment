extends Node2D

var player
@export var follow_speed := 80.

@onready var hp := 3

signal died

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"../Player"
	$Sprite2D.material.set_shader_parameter("clr", Vector3(1., 0., 0.))
	died.connect(get_parent().killed_enemy)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hp > 0:
		look_at(player.global_position)
		global_position += follow_speed * (player.global_position - global_position).normalized() * delta
	if scale.x < 0.00001:
		queue_free()
func spriteFlash(value : Vector3) -> void:
	$Sprite2D.material.set_shader_parameter("clr", value)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not area.get_parent().visible: return
	var new_pos = global_position - 30. * (player.global_position - global_position).normalized()
	create_tween().tween_property(self, "global_position", new_pos, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	create_tween().tween_method(spriteFlash, Vector3(1., 1., 1.), Vector3(1., 0., 0.), 0.32).set_trans(Tween.TRANS_QUAD)
	area.get_parent().visible = false
	hp -= 1
	if hp == 0:
		create_tween().tween_property(self, "scale", Vector2(0., 0.), 0.8).set_trans(Tween.TRANS_BACK)
		$Label.visible = true
		$Label.global_position = global_position + Vector2(60, -30)
		$Label.set_rotation(-rotation)
		create_tween().tween_property($Label, "global_position", $Label.global_position - Vector2(0., 50.), 0.5)
		create_tween().tween_property($Label, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)
		died.emit()
