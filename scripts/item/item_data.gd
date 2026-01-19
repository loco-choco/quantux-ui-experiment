class_name ItemData extends Resource

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

@export var properties: Array[ItemProperty]

func get_property(propertyScript : Script) -> ItemProperty:
	for p : ItemProperty in properties:
		if is_instance_of(p, propertyScript):
			return p 
	return null
