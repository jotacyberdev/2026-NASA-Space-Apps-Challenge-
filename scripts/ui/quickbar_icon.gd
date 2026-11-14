extends Control

var item_id := "rations":
	set(value):
		item_id = value
		queue_redraw()

func _draw() -> void:
	match item_id:
		"rations":
			_draw_rations()
		"water_bottle":
			_draw_water_bottle()
		"medkit":
			_draw_medkit()
		"metal":
			_draw_metal()
		"polymer":
			_draw_polymer()
		"seeds":
			_draw_seeds()
		"spare_parts":
			_draw_spare_parts()

func _draw_rations() -> void:
	draw_rect(Rect2(7, 5, 14, 3), Color("#DCE7E8"), true)
	draw_rect(Rect2(5, 8, 18, 12), Color("#C85D3E"), true)
	draw_rect(Rect2(5, 8, 18, 12), Color("#F4B66A"), false, 1.2)
	draw_line(Vector2(8, 11), Vector2(20, 11), Color("#F4D7A5"), 1.4, true)
	draw_line(Vector2(8, 16), Vector2(20, 16), Color("#7C352B"), 1.2, true)

func _draw_water_bottle() -> void:
	var bottle := PackedVector2Array([
		Vector2(10, 4), Vector2(18, 4), Vector2(18, 8), Vector2(21, 10),
		Vector2(21, 20), Vector2(7, 20), Vector2(7, 10), Vector2(10, 8)
	])
	draw_colored_polygon(bottle, Color("#168EAD"))
	draw_polyline(bottle, Color("#9CE8EE"), 1.2, true)
	draw_rect(Rect2(11, 2, 6, 3), Color("#E3EDF0"), true)
	draw_line(Vector2(10, 11), Vector2(10, 17), Color(0.74, 0.96, 0.98, 0.75), 1.4, true)
	draw_line(Vector2(10, 18), Vector2(18, 18), Color("#8ADDE7"), 1.0, true)

func _draw_medkit() -> void:
	draw_rect(Rect2(5, 5, 18, 15), Color("#D8464F"), true)
	draw_rect(Rect2(5, 5, 18, 15), Color("#F5B5AA"), false, 1.2)
	draw_rect(Rect2(12, 8, 4, 9), Color.WHITE, true)
	draw_rect(Rect2(9, 10, 10, 4), Color.WHITE, true)

func _draw_metal() -> void:
	var ingot := PackedVector2Array([
		Vector2(4, 9), Vector2(8, 5), Vector2(20, 5), Vector2(24, 9),
		Vector2(21, 18), Vector2(7, 18)
	])
	draw_colored_polygon(ingot, Color("#8EABB6"))
	draw_polyline(ingot, Color("#D2E0E2"), 1.2, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(8, 7), Vector2(19, 7), Vector2(15, 11), Vector2(6, 11)
	]), Color("#D5E4E5"))
	draw_line(Vector2(7, 15), Vector2(20, 15), Color("#607984"), 1.2, true)

func _draw_polymer() -> void:
	var crystal := PackedVector2Array([
		Vector2(14, 3), Vector2(22, 8), Vector2(21, 16),
		Vector2(14, 21), Vector2(6, 16), Vector2(6, 8)
	])
	draw_colored_polygon(crystal, Color("#5F9BB0"))
	draw_polyline(crystal, Color("#B3E3E5"), 1.4, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(14, 5), Vector2(19, 9), Vector2(14, 12), Vector2(9, 9)
	]), Color(0.82, 0.95, 0.93, 0.68))
	draw_line(Vector2(14, 12), Vector2(14, 19), Color("#C6E9E6"), 1.0, true)

func _draw_seeds() -> void:
	draw_line(Vector2(14, 20), Vector2(14, 8), Color("#8CCB83"), 1.6, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(14, 14), Vector2(7, 11), Vector2(6, 7), Vector2(11, 8)
	]), Color("#79B978"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(14, 11), Vector2(17, 5), Vector2(22, 4), Vector2(21, 9)
	]), Color("#A3D38A"))
	draw_circle(Vector2(14, 20), 2.2, Color("#D8A15B"))

func _draw_spare_parts() -> void:
	draw_circle(Vector2(14, 12), 8.0, Color("#899BA0"))
	draw_circle(Vector2(14, 12), 4.0, Color("#14232B"))
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var tooth := Vector2(cos(angle), sin(angle)) * 10.0
		draw_line(Vector2(14, 12) + tooth * 0.7, Vector2(14, 12) + tooth, Color("#C8D4D3"), 2.2, true)
	draw_circle(Vector2(20, 17), 3.2, Color("#E3A34C"))
	draw_line(Vector2(18, 19), Vector2(23, 14), Color("#613E28"), 1.4, true)