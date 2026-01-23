class_name Main extends Node2D

const ruid_size : int = 12
var random_user_id : String

@export var tutorial_world : PackedScene
@export var regular_world : PackedScene
var current_world : RoundWorld

var collect_data : bool
var collected_round_data : Array[RoundData] = []

@onready var main_menu : CanvasLayer = $%MainMenu

@onready var round_sumary : CanvasLayer = $%RoundSumary
@onready var game_over : Label = $%GameOver
@onready var game_won : VBoxContainer = $%GameWon
@onready var score : Label = $%Score

func _ready() -> void:
	collect_data = false
	random_user_id = generate_ruid()
	round_sumary.hide()
	InputMode.change_mode(InputMode.Modes.MENU)

func generate_ruid() -> String:
	var ruid : String = ""
	for i in range(ruid_size):
		ruid = ruid + char(randi_range(ord('a'), ord('z')))
	return ruid

func go_to_round_world(world : PackedScene) -> void:
	main_menu.hide()
	current_world = world.instantiate() as RoundWorld
	get_tree().root.add_child(current_world)
	current_world.round_logic.round_over.connect(_on_world_finish)

func _on_world_finish(points: int) -> void:
	return_from_world(points)
	current_world.queue_free()

func return_from_world(points: int) -> void:	
	if collect_data:
		var data : RoundData = RoundData.new()
		data.bag_frames = current_world.round_data_collection.bag_frames
		data.inventory_events = current_world.round_data_collection.inventory_events
		data.mouse_frames = current_world.round_data_collection.mouse_frames
		data.wave_frames = current_world.round_data_collection.wave_frames
		collected_round_data.append(data)
	round_sumary.show()
	if points >= 0:
		game_over.hide()
		game_won.show()
		score.text = "{0}".format([points])
	else:
		game_over.show()
		game_won.hide()

func _on_enable_data_collection_toggled(toggled_on: bool) -> void:
	collect_data = toggled_on
	if not collect_data:
		collected_round_data.clear()

func _on_start_game_pressed() -> void:
	go_to_round_world(regular_world)

func _on_return_pressed() -> void:
	main_menu.show()
	round_sumary.hide()

func _on_export_data_pressed() -> void:
	for i in range(collected_round_data.size()):
		collected_round_data[i].save_zip_archive("user://{0}_round_{1}.zip".format([random_user_id, i]))
