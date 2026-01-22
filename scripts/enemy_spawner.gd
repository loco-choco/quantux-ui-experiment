class_name EnemyWaveLogic extends Node2D

signal wave_completed(wave: int)
signal last_wave_completed()

@export var enemy_scene : PackedScene

@export var enemy_waves : Array[EnemyWave]
@export var current_wave : int = 0

@export var player : Player
@export var spawn_radius : float

@onready var next_wave_timer : Timer = $NextWaveTimer

var current_alive_enemies : Array[Enemy]
func _ready() -> void:
	spawn_wave()
	next_wave_timer.timeout.connect(spawn_wave)

func spawn_wave() -> void:
	if current_wave >= enemy_waves.size():
		return
	var wave : EnemyWave = enemy_waves[current_wave]
	for i in range(wave.amount_of_enemies):
		var enemy : Enemy = enemy_scene.instantiate()
		var pos : Vector2 = Vector2.from_angle(randf_range(0, TAU)) * spawn_radius
		enemy.global_position = pos + player.global_position
		enemy.target = player
		enemy.follow_speed = enemy.follow_speed * wave.enemy_speed_mult
		var current_spawn : int = randi_range(0, wave.possible_spawns.size() - 1)\
								  if not wave.all_unique else i % wave.possible_spawns.size()
		enemy.color_code = wave.possible_spawns[current_spawn]
		current_alive_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died)
		add_child(enemy)
	print("spawned wave")

func _on_enemy_died(enemy: Enemy) -> void:
	current_alive_enemies.erase(enemy)
	if current_alive_enemies.size() <= 0:
		print("Wave ", current_wave, " completed!")
		wave_completed.emit(current_wave)
		current_wave = current_wave + 1
		next_wave_timer.start()
		if current_wave >= enemy_waves.size():
			print("All waves completed!")
			last_wave_completed.emit()
