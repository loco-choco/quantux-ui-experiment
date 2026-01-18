class_name InventoryItemOption extends PanelContainer

@onready var selected = $%Selected
@onready var label = $%Label

@export var option_data : String = ""

signal lost_focus()
signal option_selected(option_data: String)

func _ready() -> void:
	if option_data:
		label.set_text(option_data)

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER_SELF:
		grab_focus()
	elif what == NOTIFICATION_FOCUS_ENTER:
		selected.show()
	elif what == NOTIFICATION_FOCUS_EXIT:
		selected.hide()
		lost_focus.emit()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_select"):
		option_selected.emit(option_data)

	
	
