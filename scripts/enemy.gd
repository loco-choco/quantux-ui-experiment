extends Node2D

var player
var clrCode
var clrRef : Vector3
var follow_speed : float

@onready var hp := 3

signal died
signal wrong_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = $"../Player"
	var clrDice = randi() % 3
	clrCode = ['r', 'g', 'b'][clrDice]
	clrRef = [Vector3(1., 0., 0.), Vector3(0., 1., 0.), Vector3(0., 0.5, 1.)][clrDice]
	$Sprite2D.material.set_shader_parameter("clr", clrRef)
	died.connect(get_parent().killed_enemy)
	wrong_color.connect(get_parent().wrong_color_popup)
	follow_speed = randf_range(60., 100.)

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
	if area.get_parent().clrCode != clrCode:
		if not area.get_parent().is_big:
			area.get_parent().visible = false
		wrong_color.emit(global_position + Vector2(60, -30))
		return
	var new_pos = global_position - 30. * (player.global_position - global_position).normalized()
	create_tween().tween_property(self, "global_position", new_pos, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	create_tween().tween_method(spriteFlash, Vector3(1., 1., 1.), clrRef, 0.32).set_trans(Tween.TRANS_QUAD)
	if not area.get_parent().is_big:
		area.get_parent().visible = false
		hp -= 1
	else:
		hp = 0
	if hp == 0:
		create_tween().tween_property(self, "scale", Vector2(0., 0.), 0.8).set_trans(Tween.TRANS_BACK)
		$Label.text = "+1000"
		$Label.visible = true
		$Label.global_position = global_position + Vector2(60, -30)
		$Label.set_rotation(-rotation)
		$Label.remove_theme_color_override("font_color")
		$Label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		create_tween().tween_property($Label, "global_position", $Label.global_position - Vector2(0., 50.), 0.5)
		create_tween().tween_property($Label, "theme_override_colors/font_color", Color(1., 1., 1., 0.), 0.5)
		died.emit(self)
