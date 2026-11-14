extends Control

var gender := "female":
	set(value):
		gender = value
		queue_redraw()

func _draw() -> void:
	var center := Vector2(38, 38)
	var accent := Color("#E58BA0") if gender == "female" else Color("#62C8DF")
	draw_circle(center + Vector2(0, 3), 34, Color(0.0, 0.0, 0.0, 0.28))
	draw_circle(center, 33, Color("#263642"))
	draw_arc(center, 32, 0.0, TAU, 48, Color("#91A7B3"), 2.0, true)
	draw_arc(center, 28, -2.45, 0.65, 24, accent, 2.0, true)

	var helmet := PackedVector2Array([
		Vector2(18, 30), Vector2(20, 19), Vector2(29, 11), Vector2(45, 11),
		Vector2(55, 20), Vector2(58, 31), Vector2(55, 48), Vector2(47, 57),
		Vector2(27, 57), Vector2(19, 47)
	])
	draw_colored_polygon(helmet, Color("#DCE7EA"))
	draw_polyline(helmet, Color("#718895"), 2.0, true)
	draw_line(Vector2(24, 51), Vector2(51, 51), Color("#718895"), 2.0, true)

	var visor := PackedVector2Array([
		Vector2(21, 28), Vector2(29, 20), Vector2(46, 20), Vector2(53, 28),
		Vector2(50, 42), Vector2(44, 48), Vector2(29, 46), Vector2(23, 40)
	])
	draw_colored_polygon(visor, Color("#123447"))
	draw_polyline(visor, Color("#53BFD0"), 1.5, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(27, 28), Vector2(33, 23), Vector2(39, 23), Vector2(31, 34), Vector2(26, 36)
	]), Color(0.70, 0.93, 0.96, 0.48))
	draw_line(Vector2(38, 25), Vector2(47, 25), Color(0.70, 0.93, 0.96, 0.28), 1.0, true)

	draw_circle(Vector2(59, 57), 7, Color("#17242D"))
	draw_circle(Vector2(59, 57), 4, accent)
	draw_circle(Vector2(58, 56), 1.2, Color.WHITE)