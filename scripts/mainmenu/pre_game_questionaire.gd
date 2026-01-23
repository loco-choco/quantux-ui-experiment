class_name PreGameQuestionnaire extends PanelContainer

signal finished_questionnaire()

var questionnaire_data : PreGameQuestionnaireData = PreGameQuestionnaireData.new()

### Personal Information
@export var age_group: OptionButton

### Game Habits
@export var gaming_frequency: HSlider
@export var game_genres: Container
@export var game_genres_other: TextEdit

### Inventory Contact
@export var inventory_used_frequency: HSlider
@export var inventory_types: Container
@export var inventory_types_other: TextEdit

@onready var finish : Button = $%Finish

func _ready() -> void:
	finish.pressed.connect(func(): finished_questionnaire.emit(); print("finished!"))
	
	### Personal Information
	age_group.item_selected.connect(func(index : int) : \
			  questionnaire_data.age_group = age_group.get_item_text(index))
	### Game Habits
	gaming_frequency.value_changed.connect(func(val : float): \
			  questionnaire_data.gaming_frequency = val)
	for c in game_genres.get_children():
		if not c is CheckBox:
			continue
		var box : CheckBox = c as CheckBox
		box.toggled.connect(func(toggled : bool) : \
		if toggled:
			questionnaire_data.game_genres.append(box.text)
		else:
			questionnaire_data.game_genres.erase(box.text))
	game_genres_other.text_changed.connect(func(): \
		questionnaire_data.game_genres_other = game_genres_other.text)
	### Inventory Contact
	inventory_used_frequency.value_changed.connect(func(val : float): \
			  questionnaire_data.inventory_used_frequency = val)
	for c in inventory_types.get_children():
		if not c is CheckBox:
			continue
		var box : CheckBox = c as CheckBox
		box.toggled.connect(func(toggled : bool) : \
		if toggled:
			questionnaire_data.inventory_types.append(box.text)
		else:
			questionnaire_data.inventory_types.erase(box.text))
	inventory_types_other.text_changed.connect(func(): \
		questionnaire_data.inventory_types_other = inventory_types_other.text)
