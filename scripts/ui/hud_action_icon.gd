extends Control

var action_id := "inventory"

func _draw() -> void:
	var center := size * 0.5
	var copper := Color("#FF9E2C")
	match action_id:
		"construction":
			draw_line(center + Vector2(-9, 8), center + Vector2(8, -9), copper, 4.0, true)
			draw_line(center + Vector2(-7, -8), center + Vector2(8, 7), Color("#F3EEE7"), 3.0, true)
			draw_circle(center + Vector2(8, -9), 4.0, copper, false, 1.5)
		"inventory":
			draw_rect(Rect2(center + Vector2(-9, -8), Vector2(18, 19)), Color("#F3EEE7"), false, 1.7)
			draw_line(center + Vector2(-5, -3), center + Vector2(5, -3), copper, 1.5, true)
			draw_line(center + Vector2(-5, 2), center + Vector2(5, 2), copper, 1.5, true)
			draw_line(center + Vector2(-5, 7), center + Vector2(2, 7), copper, 1.5, true)
		"map":
			draw_arc(center, 9.0, 0.0, TAU, 30, copper, 1.7, true)
			draw_line(center + Vector2(-9, 4), center + Vector2(1, -6), Color("#F3EEE7"), 1.3, true)
			draw_line(center + Vector2(1, -6), center + Vector2(9, 2), Color("#F3EEE7"), 1.3, true)
			draw_circle(center + Vector2(-8, 4), 2.0, copper)
			draw_circle(center + Vector2(1, -6), 2.0, copper)
			draw_circle(center + Vector2(9, 2), 2.0, copper)
		"settings":
			draw_circle(center, 8.0, copper, false, 2.0)
			draw_circle(center, 3.0, Color("#F3EEE7"), false, 1.6)
			for angle in [0.0, PI * 0.25, PI * 0.5, PI * 0.75, PI, PI * 1.25, PI * 1.5, PI * 1.75]:
				draw_line(center + Vector2(cos(angle), sin(angle)) * 9.0, center + Vector2(cos(angle), sin(angle)) * 12.0, copper, 2.0, true)
