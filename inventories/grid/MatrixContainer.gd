class_name MatrixContainer extends Container

@export var columns: int = 1
@export var rows: int = 1

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		# Must re-sort the children
		var space_per_child  = Vector2(size.x / columns, size.y / rows)
		var x : int = 0
		var y : int = 0
		print(size)
		print(space_per_child)
		for c in get_children():
			var child_pos : Vector2 = space_per_child * Vector2(x,y)
			fit_child_in_rect(c, Rect2(child_pos, space_per_child))
			if x == columns - 1:
				y = (y + 1) % rows
			x = (x + 1) % columns
			

func set_some_setting():
	queue_sort()
