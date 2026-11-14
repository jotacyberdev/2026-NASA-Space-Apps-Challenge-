extends Control

var gender := "female"
var pet := "dog"
var idle_time := 0.0

func set_selection(selected_gender: String, selected_pet: String) -> void:
	gender = selected_gender
	pet = selected_pet
	queue_redraw()

func _process(delta: float) -> void:
	idle_time += delta
	queue_redraw()

func _draw() -> void:
	var ground_y := size.y * 0.86
	for band in range(12):
		var band_rect := Rect2(0, size.y * float(band) / 12.0, size.x, size.y / 12.0 + 1)
		var color := Color("#28140F").lerp(Color("#5B2C17"), float(band) / 12.0)
		draw_rect(band_rect, color, true)
	draw_arc(Vector2(size.x * 0.5, ground_y), size.x * 0.46, PI, TAU, 60, Color(0.95, 0.40, 0.12, 0.23), 1.0, true)
	var astronaut_center := Vector2(size.x * 0.53, ground_y - 76 + sin(idle_time * 1.2) * 2.0)
	_draw_astronaut(astronaut_center)
	var pet_center := Vector2(size.x * 0.27, ground_y - 14 + sin(idle_time * 2.2 + 1.0) * 1.5)
	_draw_pet(pet_center)
	draw_line(Vector2(0, ground_y), Vector2(size.x, ground_y), Color("#E86A17"), 2.0, true)

func _draw_astronaut(center: Vector2) -> void:
	var suit := Color("#D8D6CD") if gender == "female" else Color("#C7D0D0")
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24, -23), center + Vector2(24, -23), center + Vector2(28, 26),
		center + Vector2(17, 43), center + Vector2(-17, 43), center + Vector2(-28, 26)
	]), suit)
	draw_line(center + Vector2(-12, 38), center + Vector2(-15, 72), Color("#AEB8B6"), 11.0, true)
	draw_line(center + Vector2(12, 38), center + Vector2(15, 72), Color("#AEB8B6"), 11.0, true)
	draw_line(center + Vector2(-13, 69), center + Vector2(-22, 72), Color("#392016"), 8.0, true)
	draw_line(center + Vector2(13, 69), center + Vector2(22, 72), Color("#392016"), 8.0, true)
	draw_circle(center + Vector2(0, -42), 25.0, Color("#E4E3D8"))
	draw_circle(center + Vector2(0, -43), 18.0, Color("#173B49"))
	draw_arc(center + Vector2(-2, -45), 14.0, -2.7, -0.5, 28, Color(0.68, 0.91, 0.92, 0.78), 2.0, true)
	draw_rect(Rect2(center + Vector2(-8, -8), Vector2(16, 20)), Color("#513020"), true)
	draw_rect(Rect2(center + Vector2(-5, -5), Vector2(10, 4)), Color("#F3A04A"), true)
	draw_line(center + Vector2(-24, -8), center + Vector2(-34, 20), suit, 10.0, true)
	draw_line(center + Vector2(24, -8), center + Vector2(34, 20), suit, 10.0, true)

func _draw_pet(center: Vector2) -> void:
	var is_laika := pet == "dog"
	var fur := Color("#D9C5A3") if is_laika else Color("#8D7055")
	var dark := Color("#754C36") if is_laika else Color("#534134")
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28, -10), center + Vector2(-18, -28), center + Vector2(12, -30),
		center + Vector2(27, -16), center + Vector2(24, 8), center + Vector2(12, 20),
		center + Vector2(-18, 18), center + Vector2(-30, 7)
	]), fur)
	draw_circle(center + Vector2(20, -23), 15.0, fur)
	if is_laika:
		draw_colored_polygon(PackedVector2Array([center + Vector2(10, -33), center + Vector2(9, -51), center + Vector2(20, -37)]), dark)
		draw_colored_polygon(PackedVector2Array([center + Vector2(23, -35), center + Vector2(35, -48), center + Vector2(32, -30)]), dark)
	else:
		draw_circle(center + Vector2(14, -34), 5.0, Color("#CFA86E"))
		draw_circle(center + Vector2(28, -34), 5.0, Color("#CFA86E"))
	draw_circle(center + Vector2(26, -23), 1.7, Color("#16110E"))
	draw_circle(center + Vector2(31, -15), 2.0, Color("#241610"))
	for leg_x in [-18.0, 12.0]:
		draw_line(center + Vector2(leg_x, 13), center + Vector2(leg_x, 29), dark, 5.0, true)
	draw_line(center + Vector2(-28, -9), center + Vector2(-39, -18), fur, 4.0, true)
