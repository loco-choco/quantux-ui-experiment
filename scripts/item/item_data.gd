class_name ItemData extends Resource

@export var name: String
@export var texture: Texture2D
@export var dimensions: Vector2i

@export var properties: Array[ItemProperty]

func get_property(propertyTag : String) -> ItemProperty:
	for p : ItemProperty in properties:
		if p.get_property_name().begins_with(propertyTag):
			return p 
	return null
