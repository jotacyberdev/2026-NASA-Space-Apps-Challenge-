extends Control

func _draw() -> void:
	if size.x < 10.0 or size.y < 10.0:
		return
	var arc_points := PackedVector2Array()
	for index in range(25):
		var ratio := float(index) / 24.0
		var x := lerpf(size.x * 0.30, size.x * 0.78, ratio)
		var y := size.y * (0.72 - 0.36 * sin(ratio * PI))
		arc_points.append(Vector2(x, y))
	draw_polyline(arc_points, Color(1.0, 0.62, 0.23, 0.8), 2.0, true)
	var rocket_center := Vector2(size.x * 0.77, size.y * 0.32)
	draw_set_transform(rocket_center, deg_to_rad(-38.0))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, 0), Vector2(-4, -7), Vector2(17, 0), Vector2(-4, 7)]), Color("#E8E7E1"))
	draw_colored_polygon(PackedVector2Array([Vector2(-8, -4), Vector2(-17, -10), Vector2(-14, -2)]), Color("#A9B2B4"))
	draw_colored_polygon(PackedVector2Array([Vector2(-8, 4), Vector2(-17, 10), Vector2(-14, 2)]), Color("#A9B2B4"))
	draw_circle(Vector2(5, 0), 2.0, Color("#E86A17"))
	draw_colored_polygon(PackedVector2Array([Vector2(-20, -2), Vector2(-29, 0), Vector2(-20, 2)]), Color("#FF8C24"))
	draw_set_transform(Vector2.ZERO)
