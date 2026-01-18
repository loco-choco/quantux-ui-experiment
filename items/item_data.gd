class_name ItemData extends Resource

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

@export var properties: Array[ItemProperty]

func get_property(propertyClass : String) -> ItemProperty:
	for p : ItemProperty in properties:
		if p.is_class(propertyClass):
			return p 
	return null
