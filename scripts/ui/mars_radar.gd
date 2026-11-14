extends Control

const WORLD_SIZE := Vector2(2000.0, 1200.0)
const CAMP_POSITION := Vector2(980.0, 650.0)
const IMPACT_POSITION := Vector2(1750.0, 900.0)
const EXPEDITION_POSITION := Vector2(1510.0, 950.0)

var player_position := CAMP_POSITION
var tutorial_step := 0
var pulse_phase := 0.0

func set_map_state(new_player_position: Vector2, new_tutorial_step: int) -> void:
	player_position = new_player_position
	tutorial_step = new_tutorial_step
	queue_redraw()

func _process(delta: float) -> void:
	pulse_phase = fmod(pulse_phase + delta * 2.2, TAU)
	queue_redraw()

func _draw() -> void:
	var bounds := Rect2(Vector2.ZERO, size)
	if bounds.size.x < 32.0 or bounds.size.y < 32.0:
		return

	var map_rect := bounds.grow_individual(0.0, 0.0, 0.0, 0.0)
	draw_rect(map_rect, Color("#140A06"), true)
	draw_rect(map_rect, Color("#8D3B1B"), false, 1.0)
	_draw_grid(map_rect)
	_draw_contours(map_rect)
	_draw_map_markers(map_rect)
	_draw_legend(Vector2(16.0, size.y - 16.0))

func _draw_grid(map_rect: Rect2) -> void:
	var grid_color := Color(0.85, 0.45, 0.18, 0.22)
	var label_color := Color(0.92, 0.68, 0.48, 0.75)
	var font := ThemeDB.fallback_font
	for column in range(1, 8):
		var x := map_rect.position.x + map_rect.size.x * float(column) / 8.0
		draw_line(Vector2(x, map_rect.position.y), Vector2(x, map_rect.end.y), grid_color, 1.0)
		draw_string(font, Vector2(x + 3.0, map_rect.position.y + 14.0), "%02d" % (column * 25), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, label_color)
	for row in range(1, 5):
		var y := map_rect.position.y + map_rect.size.y * float(row) / 5.0
		draw_line(Vector2(map_rect.position.x, y), Vector2(map_rect.end.x, y), grid_color, 1.0)
		draw_string(font, Vector2(map_rect.position.x + 4.0, y - 3.0), "%02d" % (row * 20), HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, label_color)

func _draw_contours(map_rect: Rect2) -> void:
	var centers := [Vector2(0.23, 0.31), Vector2(0.69, 0.26), Vector2(0.42, 0.72), Vector2(0.84, 0.68)]
	for center_index in range(centers.size()):
		var center := map_rect.position + Vector2(centers[center_index].x * map_rect.size.x, centers[center_index].y * map_rect.size.y)
		for ring in range(1, 5):
			var radius := float(ring) * (12.0 + float(center_index % 2) * 4.0)
			var points := PackedVector2Array()
			for segment in range(41):
				var angle := TAU * float(segment) / 40.0
				var ripple := 1.0 + 0.08 * sin(angle * 3.0 + float(center_index))
				points.append(center + Vector2(cos(angle) * radius * 1.65, sin(angle) * radius * ripple))
			draw_polyline(points, Color(0.78, 0.50, 0.36, 0.12 + float(ring) * 0.012), 1.0, true)

func _draw_map_markers(map_rect: Rect2) -> void:
	var camp := _world_to_map(map_rect, CAMP_POSITION)
	var impact := _world_to_map(map_rect, IMPACT_POSITION)
	var expedition := _world_to_map(map_rect, EXPEDITION_POSITION)
	var player := _world_to_map(map_rect, player_position)
	var route_target := expedition
	if tutorial_step == 0:
		route_target = _world_to_map(map_rect, Vector2(1060.0, 650.0))
	elif tutorial_step in [3, 4]:
		route_target = _world_to_map(map_rect, Vector2(930.0, 900.0))
	elif tutorial_step in [1, 2, 5, 6]:
		route_target = camp
	draw_line(camp, route_target, Color(0.95, 0.55, 0.20, 0.45), 1.5, true)
	_draw_base_marker(camp)
	_draw_impact_marker(impact)
	_draw_expedition_marker(expedition)
	_draw_player_marker(player)
	var font := ThemeDB.fallback_font
	draw_string(font, camp + Vector2(10.0, -7.0), "BASE", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color("#FFA733"))
	draw_string(font, impact + Vector2(-72.0, -9.0), "IMPACTO", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color("#E65100"))
	draw_string(font, expedition + Vector2(10.0, 15.0), "EXPEDIÇÃO", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color("#FFB74D"))
	var player_label_offset := Vector2(9.0, -9.0)
	if player.distance_to(camp) < 30.0:
		player_label_offset = Vector2(9.0, 19.0)
	draw_string(font, player + player_label_offset, "TRIPULAÇÃO", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color.WHITE)

func _draw_base_marker(position: Vector2) -> void:
	draw_rect(Rect2(position - Vector2(5.0, 5.0), Vector2(10.0, 10.0)), Color("#FFA733"), false, 2.0)
	draw_circle(position, 2.0, Color("#FFA733"))

func _draw_impact_marker(position: Vector2) -> void:
	draw_circle(position, 8.0, Color(0.90, 0.30, 0.15, 0.25))
	draw_line(position + Vector2(-5.0, -5.0), position + Vector2(5.0, 5.0), Color("#E65100"), 2.0, true)
	draw_line(position + Vector2(5.0, -5.0), position + Vector2(-5.0, 5.0), Color("#E65100"), 2.0, true)

func _draw_expedition_marker(position: Vector2) -> void:
	var diamond := PackedVector2Array([
		position + Vector2(0.0, -7.0), position + Vector2(7.0, 0.0),
		position + Vector2(0.0, 7.0), position + Vector2(-7.0, 0.0)
	])
	draw_colored_polygon(diamond, Color(1.0, 0.71, 0.31, 0.25))
	draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]), Color("#FFB74D"), 1.5, true)

func _draw_player_marker(position: Vector2) -> void:
	var pulse_radius := 9.0 + sin(pulse_phase) * 2.2
	draw_circle(position, pulse_radius, Color(0.95, 0.60, 0.20, 0.15))
	draw_arc(position, pulse_radius, 0.0, TAU, 40, Color(1.0, 0.70, 0.30, 0.65), 1.0, true)
	draw_circle(position, 4.0, Color("#FFF4E5"))
	draw_circle(position, 2.0, Color("#FF8800"))

func _draw_legend(origin: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var entries := [
		{"label": "BASE", "color": Color("#FFA733")},
		{"label": "IMPACTO", "color": Color("#E65100")},
		{"label": "EXPEDIÇÃO", "color": Color("#FFB74D")},
		{"label": "VOCÊ", "color": Color.WHITE}
	]
	var cursor := origin.x
	for entry in entries:
		draw_circle(Vector2(cursor + 4.0, origin.y - 4.0), 3.0, entry["color"])
		draw_string(font, Vector2(cursor + 12.0, origin.y), entry["label"], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 9, Color("#F4EEE6"))
		cursor += 94.0

func _world_to_map(map_rect: Rect2, world_position: Vector2) -> Vector2:
	var normalized := world_position / WORLD_SIZE
	return map_rect.position + Vector2(normalized.x * map_rect.size.x, normalized.y * map_rect.size.y)
