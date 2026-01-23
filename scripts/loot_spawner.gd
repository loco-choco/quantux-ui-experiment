class_name LootSpawner extends Node2D

@export var item_scene : PackedScene
@export var loot_table : Array[ItemData]
@export var loot_amount : int = 1
@export var spawn_on_ready : bool = true

func _ready() -> void:
	if spawn_on_ready:
		spawn_loot()

func spawn_loot() -> void:
	for i in range(loot_amount):
		print("spawning")
		var item_index : int = randi_range(0, loot_table.size() - 1)
		var item : Item = item_scene.instantiate()
		item.item_data = loot_table[item_index]
		add_child(item)
		item.global_position = global_position
