extends Control

var slide_index := 0
var animation_time := 0.0

func set_slide(index: int) -> void:
	slide_index = clampi(index, 0, 3)
	queue_redraw()

func _process(delta: float) -> void:
	animation_time += delta
	if slide_index == 1 or slide_index == 2 or slide_index == 3:
		queue_redraw()

func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("#101D2B"), true)
	_draw_stars(42 if slide_index == 0 else 20)
	match slide_index:
		0:
			_draw_orbit_scene()
		1:
			_draw_entry_scene()
		2:
			_draw_storm_scene()
		3:
			_draw_dawn_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.62, 0.79, 0.86, 0.42), false, 1.0)

func _draw_stars(count: int) -> void:
	for index in range(count):
		var seed_value := float(index + 1)
		var x_ratio := fposmod(seed_value * 0.6180339 + 0.13, 1.0)
		var y_ratio := fposmod(seed_value * 0.7548777 + 0.07, 0.64)
		var star_size := 1.0 + fposmod(seed_value * 0.37, 1.6)
		var flicker := 0.56 + 0.34 * sin(animation_time * 1.1 + seed_value)
		draw_circle(Vector2(size.x * x_ratio, size.y * y_ratio), star_size, Color(0.76, 0.88, 0.94, flicker))

func _draw_orbit_scene() -> void:
	_draw_sky_glow(Color("#182842"), Color("#374B61"), 0.83)
	var orbit_center := Vector2(size.x * 0.58, size.y * 0.53)
	var orbit := _ellipse_points(orbit_center, Vector2(size.x * 0.33, size.y * 0.27), 90)
	draw_polyline(orbit, Color(0.66, 0.81, 0.88, 0.42), 1.3, true)
	_draw_mars(Vector2(size.x * 0.70, size.y * 0.48), minf(size.x * 0.17, size.y * 0.31))
	_draw_station(Vector2(size.x * 0.31, size.y * 0.47), 1.0)
	draw_line(Vector2(size.x * 0.25, size.y * 0.70), Vector2(size.x * 0.58, size.y * 0.70), Color(0.48, 0.77, 0.86, 0.42), 1.0, true)

func _draw_entry_scene() -> void:
	_draw_sky_glow(Color("#13213A"), Color("#A54E35"), 0.75)
	_draw_mars_horizon(0.76, Color("#612D2B"), Color("#351C23"))
	var atmosphere := sin(animation_time * 1.6) * 2.0
	var capsule_center := Vector2(size.x * 0.54, size.y * 0.48 + atmosphere)
	var canopy_center := Vector2(capsule_center.x, size.y * 0.23 + atmosphere * 0.4)
	_draw_parachute(canopy_center, size.x * 0.15, Color("#D96D42"))
	for rope_x in [-0.78, -0.40, 0.0, 0.40, 0.78]:
		draw_line(canopy_center + Vector2(size.x * 0.15 * rope_x, size.y * 0.015), capsule_center + Vector2(size.x * 0.025 * rope_x, -size.y * 0.025), Color(0.88, 0.78, 0.66, 0.68), 1.0, true)
	_draw_capsule(capsule_center, Vector2(size.x * 0.08, size.y * 0.14), -0.12)
	draw_colored_polygon(PackedVector2Array([
		capsule_center + Vector2(-size.x * 0.025, size.y * 0.065),
		capsule_center + Vector2(size.x * 0.026, size.y * 0.065),
		capsule_center + Vector2(size.x * 0.014, size.y * 0.16 + atmosphere),
		capsule_center + Vector2(-size.x * 0.012, size.y * 0.16 + atmosphere)
	]), Color(1.0, 0.45, 0.16, 0.58))

func _draw_storm_scene() -> void:
	_draw_sky_glow(Color("#453448"), Color("#A34F35"), 0.64)
	_draw_mars_horizon(0.70, Color("#6B3430"), Color("#351A20"))
	for streak in range(18):
		var streak_seed := float(streak + 3)
		var x := fposmod(streak_seed * 0.391 + animation_time * 0.025, 1.25) * size.x - size.x * 0.12
		var y := size.y * (0.18 + fposmod(streak_seed * 0.173, 0.60))
		var length := size.x * (0.025 + fposmod(streak_seed * 0.091, 0.055))
		draw_line(Vector2(x, y), Vector2(x + length, y - size.y * 0.012), Color(0.95, 0.56, 0.34, 0.14), 2.0, true)
	var crash_center := Vector2(size.x * 0.56, size.y * 0.72)
	draw_colored_polygon(_ellipse_points(Vector2(size.x * 0.56, size.y * 0.79), Vector2(size.x * 0.22, size.y * 0.045), 44), Color(0.09, 0.035, 0.03, 0.62))
	_draw_capsule(crash_center, Vector2(size.x * 0.13, size.y * 0.16), -0.48)
	for dust_index in range(9):
		var dust_seed := float(dust_index + 4)
		var dust_pos := crash_center + Vector2(fposmod(dust_seed * 0.29, 0.30) * size.x - size.x * 0.15, -fposmod(dust_seed * 0.21, 0.10) * size.y)
		draw_circle(dust_pos, 2.0 + fposmod(dust_seed, 3.0), Color(0.91, 0.49, 0.30, 0.22))

func _draw_dawn_scene() -> void:
	_draw_sky_glow(Color("#273A57"), Color("#D77A49"), 0.62)
	_draw_mars_horizon(0.70, Color("#68312D"), Color("#2C191E"))
	var ground_line := size.y * 0.78
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, ground_line), Vector2(size.x, ground_line - size.y * 0.015),
		Vector2(size.x, size.y), Vector2(0, size.y)
	]), Color("#301A1C"))
	_draw_base_silhouette(Vector2(size.x * 0.24, ground_line), 0.78)
	draw_colored_polygon(_ellipse_points(Vector2(size.x * 0.72, ground_line + size.y * 0.025), Vector2(size.x * 0.20, size.y * 0.035), 48), Color(0.055, 0.025, 0.025, 0.66))
	_draw_capsule(Vector2(size.x * 0.70, ground_line - size.y * 0.12), Vector2(size.x * 0.14, size.y * 0.18), 0.10)
	_draw_astronaut(Vector2(size.x * 0.47, ground_line - size.y * 0.02), 1.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(size.x * 0.48, ground_line), Vector2(size.x * 0.55, ground_line),
		Vector2(size.x * 0.68, size.y), Vector2(size.x * 0.41, size.y)
	]), Color(0.02, 0.012, 0.012, 0.32))

func _draw_sky_glow(upper: Color, lower: Color, horizon_ratio: float) -> void:
	for band in range(16):
		var top := size.y * float(band) / 16.0
		var blend := clampf(float(band) / 15.0 / horizon_ratio, 0.0, 1.0)
		var color := upper.lerp(lower, blend)
		draw_rect(Rect2(0.0, top, size.x, size.y / 16.0 + 1.0), color, true)

func _draw_mars(center: Vector2, radius: float) -> void:
	draw_circle(center + Vector2(-radius * 0.12, radius * 0.08), radius * 1.14, Color(0.91, 0.34, 0.17, 0.14))
	draw_circle(center, radius, Color("#B64C32"))
	draw_circle(center + Vector2(-radius * 0.27, -radius * 0.12), radius * 0.76, Color("#D16A3D"))
	draw_arc(center, radius * 0.96, -2.72, 0.96, 56, Color("#F3A064"), 2.0, true)
	for mark in range(7):
		var mark_pos := center + Vector2(cos(float(mark) * 2.17) * radius * 0.5, sin(float(mark) * 2.17) * radius * 0.53)
		draw_arc(mark_pos, radius * (0.08 + float(mark % 3) * 0.025), 0.0, PI * 1.7, 24, Color(0.39, 0.12, 0.09, 0.42), 1.2, true)

func _draw_station(center: Vector2, scale: float) -> void:
	var core := Rect2(center - Vector2(13, 5) * scale, Vector2(26, 10) * scale)
	draw_rect(core, Color("#C8D6D9"), true)
	draw_rect(core, Color("#547482"), false, 1.2)
	draw_rect(Rect2(center + Vector2(-43, -8) * scale, Vector2(26, 16) * scale), Color("#214B64"), true)
	draw_rect(Rect2(center + Vector2(17, -8) * scale, Vector2(26, 16) * scale), Color("#214B64"), true)
	for offset in [-43.0, 17.0]:
		for cell in range(1, 4):
			draw_line(center + Vector2(offset + cell * 6.5, -8) * scale, center + Vector2(offset + cell * 6.5, 8) * scale, Color("#72C9D7", 0.62), 0.8, true)
			draw_line(center + Vector2(offset, -8 + cell * 4.0) * scale, center + Vector2(offset + 26, -8 + cell * 4.0) * scale, Color("#72C9D7", 0.54), 0.8, true)
	draw_line(center + Vector2(-17, 0) * scale, center + Vector2(-43, 0) * scale, Color("#CED9D8"), 2.0, true)
	draw_line(center + Vector2(13, 0) * scale, center + Vector2(17, 0) * scale, Color("#CED9D8"), 2.0, true)

func _draw_mars_horizon(horizon_ratio: float, far_color: Color, near_color: Color) -> void:
	var horizon := size.y * horizon_ratio
	var far_points := PackedVector2Array([Vector2(0, horizon)])
	for sample in range(17):
		var x := size.x * float(sample) / 16.0
		var ridge: float = horizon - size.y * (0.035 + 0.07 * abs(sin(float(sample) * 1.73)))
		far_points.append(Vector2(x, ridge))
	far_points.append(Vector2(size.x, size.y))
	far_points.append(Vector2(0, size.y))
	draw_colored_polygon(far_points, far_color)
	var near_points := PackedVector2Array([Vector2(0, horizon + size.y * 0.05)])
	for sample in range(17):
		var x := size.x * float(sample) / 16.0
		var ridge: float = horizon + size.y * (0.05 + 0.025 * sin(float(sample) * 1.31 + 1.0))
		near_points.append(Vector2(x, ridge))
	near_points.append(Vector2(size.x, size.y))
	near_points.append(Vector2(0, size.y))
	draw_colored_polygon(near_points, near_color)

func _draw_parachute(center: Vector2, width: float, color: Color) -> void:
	var canopy := PackedVector2Array([center + Vector2(-width * 0.5, 0.0)])
	for segment in range(17):
		var angle := PI + PI * float(segment) / 16.0
		canopy.append(center + Vector2(cos(angle) * width * 0.5, sin(angle) * width * 0.58))
	canopy.append(center + Vector2(width * 0.5, 0.0))
	draw_colored_polygon(canopy, color)
	draw_polyline(canopy, Color("#FFD1A0"), 1.4, true)
	for rib in range(1, 5):
		var x := lerpf(-width * 0.5, width * 0.5, float(rib) / 5.0)
		draw_line(center, center + Vector2(x, -width * 0.37), Color(0.39, 0.11, 0.07, 0.66), 1.0, true)

func _draw_capsule(center: Vector2, dimensions: Vector2, angle: float) -> void:
	var shape := PackedVector2Array([
		Vector2(-0.45, -0.50), Vector2(0.27, -0.50), Vector2(0.48, -0.18),
		Vector2(0.40, 0.44), Vector2(-0.36, 0.50), Vector2(-0.50, 0.12)
	])
	var hull := _transform_points(center, dimensions, angle, shape)
	draw_colored_polygon(hull, Color("#AAB8BC"))
	draw_polyline(PackedVector2Array([hull[0], hull[1], hull[2], hull[3], hull[4], hull[5], hull[0]]), Color("#E3E8E6"), 1.4, true)
	var hatch_center := center + Vector2(cos(angle) * dimensions.x * 0.18, sin(angle) * dimensions.x * 0.18)
	draw_circle(hatch_center, minf(dimensions.x, dimensions.y) * 0.16, Color("#153849"))
	draw_arc(hatch_center, minf(dimensions.x, dimensions.y) * 0.16, 0.0, TAU, 28, Color("#73C9D6"), 1.2, true)
	draw_line(center + Vector2(-dimensions.x * 0.34, dimensions.y * 0.35), center + Vector2(-dimensions.x * 0.55, dimensions.y * 0.74), Color("#D4A45E"), 2.0, true)
	draw_line(center + Vector2(dimensions.x * 0.30, dimensions.y * 0.38), center + Vector2(dimensions.x * 0.46, dimensions.y * 0.70), Color("#D4A45E"), 2.0, true)

func _draw_base_silhouette(origin: Vector2, scale: float) -> void:
	draw_rect(Rect2(origin + Vector2(-48, -34) * scale, Vector2(100, 34) * scale), Color("#171F29"), true)
	draw_rect(Rect2(origin + Vector2(-24, -55) * scale, Vector2(48, 55) * scale), Color("#1D2730"), true)
	draw_arc(origin + Vector2(0, -55) * scale, 24.0 * scale, PI, TAU, 24, Color("#1D2730"), 4.0 * scale, true)
	for window_x in [-34.0, -14.0, 12.0, 32.0]:
		draw_rect(Rect2(origin + Vector2(window_x, -22) * scale, Vector2(7, 8) * scale), Color(0.31, 0.76, 0.82, 0.76), true)
	draw_line(origin + Vector2(-58, -2) * scale, origin + Vector2(58, -2) * scale, Color("#D18A50"), 2.0 * scale, true)

func _draw_astronaut(origin: Vector2, scale: float) -> void:
	draw_colored_polygon(PackedVector2Array([
		origin + Vector2(-15, -40) * scale, origin + Vector2(14, -40) * scale,
		origin + Vector2(21, -5) * scale, origin + Vector2(14, 14) * scale,
		origin + Vector2(-14, 14) * scale, origin + Vector2(-21, -5) * scale
	]), Color("#D6D9D3"))
	draw_rect(Rect2(origin + Vector2(-22, -13) * scale, Vector2(44, 28) * scale), Color("#B7C2C2"), true)
	draw_line(origin + Vector2(-12, 12) * scale, origin + Vector2(-16, 37) * scale, Color("#A6B4B5"), 7.0 * scale, true)
	draw_line(origin + Vector2(12, 12) * scale, origin + Vector2(16, 37) * scale, Color("#A6B4B5"), 7.0 * scale, true)
	draw_circle(origin + Vector2(0, -40) * scale, 17.0 * scale, Color("#D8E0DC"))
	draw_circle(origin + Vector2(0, -41) * scale, 12.0 * scale, Color("#153847"))
	draw_arc(origin + Vector2(-2, -43) * scale, 9.0 * scale, -2.7, -0.6, 20, Color(0.65, 0.92, 0.94, 0.78), 1.4 * scale, true)
	draw_rect(Rect2(origin + Vector2(-4, -10) * scale, Vector2(8, 12) * scale), Color("#E7984F"), true)

func _ellipse_points(center: Vector2, radii: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points

func _transform_points(center: Vector2, dimensions: Vector2, angle: float, points: PackedVector2Array) -> PackedVector2Array:
	var transformed := PackedVector2Array()
	for point in points:
		var scaled := point * dimensions
		transformed.append(center + Vector2(
			scaled.x * cos(angle) - scaled.y * sin(angle),
			scaled.x * sin(angle) + scaled.y * cos(angle)
		))
	return transformed
