class_name PreGameQuestionnaireData extends Resource

### Personal Information
@export var age_group: String = ""

### Game Habits
@export var gaming_frequency: float = 0
@export var game_genres: PackedStringArray = []
@export var game_genres_other: String = ""

### Inventory Contact
@export var inventory_used_frequency: float = 0
@export var inventory_types: PackedStringArray = []
@export var inventory_types_other: String = ""

func save_json_in_zip(zip : ZIPPacker, file_name : String = "quest.json") -> void:
	zip.start_file(file_name)
	var json_dict = {
		"age_group": age_group,
		"gaming_frequency": gaming_frequency,
		"game_genres": game_genres,
		"game_genres_other": game_genres_other,
		"inventory_used_frequency": inventory_used_frequency,
		"inventory_types": inventory_types,
		"inventory_types_other": inventory_types_other,
	}
	zip.write_file(JSON.stringify(json_dict).to_ascii_buffer())
	zip.close_file()
