class_name ItemData extends Resource

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

@export var additional_tags: PackedStringArray

var tags: PackedStringArray:
	get():
		return additional_tags

@export var additional_options: PackedStringArray = ["drop"]

var options: PackedStringArray:
	get():
		return additional_options
