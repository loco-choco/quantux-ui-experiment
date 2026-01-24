class_name Main extends Node2D

@export var tutorial_world : PackedScene
@export var regular_world : PackedScene
var current_world : RoundWorld

var collect_data : bool
var collected_round_data : Array[RoundData] = []
const forms_uri : String = "https://framaforms.org/quantux-experiment-questionnaire-1768771359"

@onready var main_menu : Control = $%MainMenu

@onready var tutorial : Control = $%Tutorial
@onready var round_sumary : Control = $%RoundSumary
@onready var game_over : Label = $%GameOver
@onready var game_won : VBoxContainer = $%GameWon
@onready var score : Label = $%Score

func _ready() -> void:
	collect_data = false
	main_menu.show()
	tutorial.hide()
	round_sumary.hide()
	InputMode.change_mode(InputMode.Modes.MENU)

func go_to_round_world(world : PackedScene) -> void:
	main_menu.hide()
	current_world = world.instantiate() as RoundWorld
	get_tree().root.add_child(current_world)
	current_world.round_logic.round_over.connect(_on_world_finish)

func _on_open_questionnaire() -> void:
	OS.shell_open(forms_uri)

func _on_world_finish(points: int) -> void:
	return_from_world(points)

func return_from_world(points: int) -> void:
	if collect_data:
		collected_round_data.append(current_world.round_data_collection.round_data)
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

func _on_round_summary_return_pressed() -> void:
	main_menu.show()
	round_sumary.hide()
	current_world.queue_free()
	
func _on_tutorial_pressed() -> void:
	main_menu.hide()
	tutorial.show()

func _on_tutorial_return_pressed() -> void:
	main_menu.show()
	tutorial.hide()

func _on_export_data_pressed() -> void:
	_export_data_as_zip()
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _export_data_as_zip() -> void:
	var file_name : String = "user://collected_data.zip"
	var zip : ZIPPacker = ZIPPacker.new()
	var error = zip.open(file_name, ZIPPacker.ZipAppend.APPEND_CREATE)
	if error != OK:
		push_error("Couldn't open path for saving ZIP archive (error code: %s)." % error_string(error))
		return
	## Saving round data
	for i : int in range(collected_round_data.size()):
		collected_round_data[i].save_to_zip_archive(zip, "round_%d/" % [i])
	
	zip.close()
