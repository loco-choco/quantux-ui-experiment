extends Node

var socket := WebSocketPeer.new()
var connected := false
var client_id: String
var session_id: String

func _ready():
	client_id = get_or_create_client_id()
	session_id = generate_id()
	var err := socket.connect_to_url("ws://localhost:8080")
	if err != OK:
		push_error("WebSocket connection failed: %s" % err)
	else:
		print("Connecting to WebSocket...")

func _process(_delta):
	socket.poll()

	var state := socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN and not connected:
		connected = true

	elif state == WebSocketPeer.STATE_CLOSED:
		if connected:
			push_error("WebSocket closed")
		connected = false

func _input(event):
	if not connected:
		return

	var datetime := Time.get_datetime_string_from_system(true)

	if event is InputEventKey:
		if event.echo:
			return

		if event.pressed:
			send_data('KEY DOWN', {
				"key": OS.get_keycode_string(event.keycode), 
				"keycode": event.keycode
			}, datetime)
		else:
			send_data('KEY UP', {
				"key": OS.get_keycode_string(event.keycode), 
				"keycode": event.keycode
			}, datetime)

	elif event is InputEventMouseButton:
		send_data("MOUSE BUTTON " + "DOWN" if event.pressed else "UP", {
			"button_index": event.button_index, 
			"position": event.position
		}, datetime)
			
	elif event is InputEventMouseMotion:
		send_data("MOUSE MOVE", {
			"position": event.position
		}, datetime)
		
func send_data(event_type, payload, datetime):
	var packet := {
		"client_id": client_id,
		"session_id": session_id,
		"timestamp": datetime,
		"type": event_type,
		"payload": payload
	}
	socket.send_text(JSON.stringify(packet))

func get_or_create_client_id() -> String:
	var path := "user://client_id.txt"

	if FileAccess.file_exists(path):
		return FileAccess.open(path, FileAccess.READ).get_line()

	var id := generate_id()
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_line(id)
	file.close()
	return id
		
func generate_id() -> String:
	var crypto := Crypto.new()
	var bytes := crypto.generate_random_bytes(16)
	return bytes.hex_encode()

func _exit_tree():
	socket.close()
