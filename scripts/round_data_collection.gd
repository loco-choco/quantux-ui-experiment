class_name RoundDataCollection extends Node

@export var inventory : Inventory
@export var bag_inventory : ItemGrid
@export var enemy_wave_logic : EnemyWaveLogic
@export var player : Player

var inventory_events : Dictionary[String, RoundData.InventoryEvent] = {}
var bag_frames : Dictionary[String, BagFrame] = {}
var wave_frames : Dictionary[String, WaveFrame] = {}
var mouse_frames : Dictionary[String, Vector2] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bag_inventory.items_update.connect(_on_bag_items_update)
	inventory.visibility_changed.connect(get_inventory_event)
	
func get_inventory_event() -> void:
	var now: String = Time.get_datetime_string_from_system(true)
	inventory_events[now] = RoundData.InventoryEvent.OPEN if inventory.visible\
					   else RoundData.InventoryEvent.CLOSE

func _on_bag_items_update(items: Array[InventoryItem]) -> void:
	var total_value : int = 0
	for item : InventoryItem in items:
		var valuable : ValuableItemProperty = item.data.get_property("valuable")
		if valuable:
			total_value = total_value + valuable.value
	get_current_bag_frame(total_value)

func get_current_bag_frame(value : int) -> void:
	var now: String = Time.get_datetime_string_from_system(true)
	var bag_frame : BagFrame = BagFrame.new()
	var current_slot : int = 0
	for s : InventorySlot in bag_inventory.get_children():
		var x : int = current_slot % bag_inventory.columns
		@warning_ignore("integer_division")
		var y : int = current_slot / bag_inventory.columns
		if s.item_in_slot:
			var item : ItemData = s.item_in_slot.data
			var slot_frame : SlotFrame = SlotFrame.new()
			slot_frame.item_name = item.name
			bag_frame.frame[Vector2i(x,y)] = slot_frame
		current_slot = current_slot + 1
	bag_frame.current_value = value
	bag_frames[now] = bag_frame

func get_current_wave_status() -> void:
	var now: String = Time.get_datetime_string_from_system(true)
	var frame : WaveFrame = WaveFrame.new()
	var amount : int = 0
	var closest : float = INF
	for c in enemy_wave_logic.get_children():
		var enemy : Enemy = c as Enemy
		if enemy:
			amount = amount + 1
			var dist : float = (enemy.target.global_position - enemy.global_position).length()
			if dist < closest:
				closest = dist
	frame.amount_of_enemies = amount
	frame.closest_distance_to_player = closest
	wave_frames[now] = frame
	
func get_current_mouse_pos() -> void:
	var now: String = Time.get_datetime_string_from_system(true)
	mouse_frames[now] = get_viewport().get_mouse_position()
