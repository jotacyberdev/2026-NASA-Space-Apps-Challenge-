extends Node2D

const ASSET_REGISTRY := preload("res://scripts/core/asset_registry.gd")

var capsule_sprite: Sprite2D

func _ready() -> void:
	var texture := ASSET_REGISTRY.building_texture("crashed_ship")
	if texture == null:
		return
	capsule_sprite = Sprite2D.new()
	capsule_sprite.name = "CrashedShipSprite"
	capsule_sprite.texture = texture
	capsule_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var fit_scale := minf(290.0 / float(texture.get_width()), 180.0 / float(texture.get_height()))
	capsule_sprite.scale = Vector2.ONE * fit_scale
	add_child(capsule_sprite)
	queue_redraw()

func _draw() -> void:
	if capsule_sprite != null:
		return
	draw_colored_polygon(_ellipse_points(Vector2(0, 96), Vector2(164, 28), 56), Color(0.045, 0.022, 0.019, 0.27))
	draw_colored_polygon(_ellipse_points(Vector2(0, 94), Vector2(142, 19), 56), Color(0.055, 0.027, 0.025, 0.48))
	draw_colored_polygon(_ellipse_points(Vector2(22, 79), Vector2(111, 12), 48), Color(0.18, 0.07, 0.045, 0.25))
	draw_colored_polygon(PackedVector2Array([
		Vector2(42, 72), Vector2(97, 63), Vector2(120, 71),
		Vector2(94, 78), Vector2(54, 80)
	]), Color(0.88, 0.28, 0.12, 0.18))
	for soot_position in [Vector2(-126, 91), Vector2(-105, 107), Vector2(-73, 113), Vector2(88, 109), Vector2(123, 96)]:
		draw_colored_polygon(_ellipse_points(soot_position, Vector2(12, 3.2), 16), Color(0.11, 0.045, 0.033, 0.3))

	draw_set_transform(Vector2.ZERO, deg_to_rad(-10.0))
	_draw_landing_gear()
	var hull := PackedVector2Array([
		Vector2(-111, -8), Vector2(-98, -27), Vector2(-61, -40), Vector2(21, -39),
		Vector2(71, -27), Vector2(103, -8), Vector2(108, 8), Vector2(88, 25),
		Vector2(42, 37), Vector2(-46, 34), Vector2(-91, 20)
	])
	draw_colored_polygon(hull, Color("#829198"))
	draw_polyline(hull, Color("#D0D9D9"), 2.0, true)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-98, -27), Vector2(-61, -40), Vector2(21, -39), Vector2(71, -27),
		Vector2(41, -11), Vector2(-54, -10), Vector2(-94, -4)
	]), Color("#BAC7C9"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-94, 2), Vector2(-49, 9), Vector2(38, 13), Vector2(93, 3),
		Vector2(88, 25), Vector2(42, 37), Vector2(-46, 34), Vector2(-91, 20)
	]), Color("#47545B"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-86, -4), Vector2(-49, 2), Vector2(34, 5), Vector2(91, -5),
		Vector2(88, 1), Vector2(34, 12), Vector2(-52, 9), Vector2(-89, 3)
	]), Color("#E3A34C"))

	for band_x in [-57.0, 48.0]:
		draw_line(Vector2(band_x, -37), Vector2(band_x - 2.0, 32), Color("#4C5A60"), 2.0, true)
		draw_line(Vector2(band_x + 3.0, -36), Vector2(band_x + 1.0, 30), Color(0.86, 0.91, 0.89, 0.52), 1.0, true)

	_draw_hatch(Vector2(-36, -3))
	_draw_porthole(Vector2(15, -20), 7.0)
	_draw_porthole(Vector2(55, -14), 5.5)
	_draw_burn_marks()
	_draw_antenna()
	_draw_rivets()
	draw_set_transform(Vector2.ZERO, 0.0)

func _draw_landing_gear() -> void:
	for side in [-1.0, 1.0]:
		var upper_joint := Vector2(72.0 * side, 15)
		var lower_joint := Vector2(96.0 * side, 54)
		var foot := Vector2(115.0 * side, 61)
		draw_line(upper_joint, lower_joint, Color("#35454C"), 7.0, true)
		draw_line(upper_joint + Vector2(-2.0 * side, -1), lower_joint + Vector2(-2.0 * side, -1), Color("#C4CFCE"), 2.2, true)
		draw_line(lower_joint, foot, Color("#687A7E"), 5.0, true)
		draw_circle(lower_joint, 4.0, Color("#D89A47"))
		draw_line(foot + Vector2(-9, 0), foot + Vector2(9, 0), Color("#303E43"), 5.0, true)
		draw_line(foot + Vector2(-7, -1), foot + Vector2(7, -1), Color("#BBC7C6"), 1.4, true)

func _draw_hatch(center: Vector2) -> void:
	draw_circle(center + Vector2(0, 2), 19, Color("#38474E"))
	draw_arc(center, 18, 0.0, TAU, 48, Color("#D4DEDE"), 2.4, true)
	draw_circle(center, 14, Color("#68777C"))
	draw_circle(center, 10.5, Color("#1C3540"))
	draw_arc(center + Vector2(-1, -1), 8.0, -2.6, -0.5, 24, Color(0.57, 0.86, 0.9, 0.75), 1.4, true)
	for bolt_angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var bolt_position := center + Vector2(cos(bolt_angle), sin(bolt_angle)) * 15.5
		draw_circle(bolt_position, 1.2, Color("#E3B66F"))

func _draw_porthole(center: Vector2, radius: float) -> void:
	draw_circle(center, radius + 2.0, Color("#53666E"))
	draw_circle(center, radius, Color("#173442"))
	draw_arc(center, radius, -2.6, 0.7, 24, Color("#87DDE2"), 1.4, true)
	draw_circle(center + Vector2(-radius * 0.3, -radius * 0.35), 1.5, Color(0.84, 0.96, 0.95, 0.84))

func _draw_burn_marks() -> void:
	for mark in [
		PackedVector2Array([Vector2(76, -24), Vector2(105, -9), Vector2(97, -5), Vector2(82, -13)]),
		PackedVector2Array([Vector2(83, 18), Vector2(106, 8), Vector2(97, 22), Vector2(78, 28)]),
		PackedVector2Array([Vector2(-97, -8), Vector2(-111, -3), Vector2(-103, 5), Vector2(-90, 2)])
	]:
		draw_colored_polygon(mark, Color(0.18, 0.09, 0.07, 0.82))
	draw_line(Vector2(85, -8), Vector2(103, -12), Color("#E56A31"), 2.0, true)
	draw_line(Vector2(83, 18), Vector2(98, 12), Color("#C64A2D"), 2.0, true)

func _draw_antenna() -> void:
	draw_line(Vector2(66, -25), Vector2(78, -54), Color("#263940"), 3.0, true)
	draw_line(Vector2(78, -54), Vector2(91, -66), Color("#CED9D8"), 2.0, true)
	draw_arc(Vector2(95, -68), 7.0, -2.4, 0.4, 20, Color("#70D8E8"), 1.4, true)
	draw_circle(Vector2(91, -66), 2.0, Color("#E7B45C"))
	draw_line(Vector2(66, -25), Vector2(73, -22), Color("#E7B45C"), 2.0, true)

func _draw_rivets() -> void:
	for rivet_position in [Vector2(-74, -20), Vector2(-73, 16), Vector2(25, -31), Vector2(68, 17)]:
		draw_circle(rivet_position, 1.5, Color("#E0C18C"))
		draw_circle(rivet_position, 0.55, Color("#394850"))

func _ellipse_points(center: Vector2, radii: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(segments):
		var angle := TAU * float(index) / float(segments)
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	return points