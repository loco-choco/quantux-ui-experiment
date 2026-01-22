class_name TutorialWorld extends Node2D

enum TutorialSteps {MOVING, UI_EXPLAIN, OPENING_INV, EQUIP_WEAPON, PASS_FIRST_ROUND,\
					NEW_WEAPON, ALL_ROUNDS}

var current_step : TutorialSteps = TutorialSteps.MOVING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _logic_for_each_step() -> void:
	pass
