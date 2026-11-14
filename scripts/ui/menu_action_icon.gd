extends Control

var action_id := "start"
var accent := Color("#FF9E2C")

func _draw() -> void:
	var frame := Rect2(Vector2(1, 1), size - Vector2(2, 2))
	draw_rect(frame, Color(0.055, 0.032, 0.025, 0.94), true)
	draw_rect(frame, accent, false, 1.4, true)
	var center := size * 0.5
	match action_id:
		"start":
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -9), center + Vector2(8, 7), center + Vector2(0, 4), center + Vector2(-8, 7)]), accent)
			draw_circle(center + Vector2(0, -1), 2.0, Color("#4E2411"))
			draw_line(center + Vector2(-4, 9), center + Vector2(0, 5), Color.WHITE, 1.3, true)
			draw_line(center + Vector2(4, 9), center + Vector2(0, 5), Color.WHITE, 1.3, true)
		"load":
			draw_rect(Rect2(center + Vector2(-8, -6), Vector2(13, 12)), accent, false, 1.7)
			draw_line(center + Vector2(-8, -8), center + Vector2(8, -8), accent, 1.7, true)
			draw_line(center + Vector2(0, 1), center + Vector2(9, 1), Color.WHITE, 1.7, true)
			draw_line(center + Vector2(5, -3), center + Vector2(9, 1), Color.WHITE, 1.7, true)
			draw_line(center + Vector2(5, 5), center + Vector2(9, 1), Color.WHITE, 1.7, true)
		"settings":
			draw_circle(center, 7.0, accent, false, 1.7)
			draw_circle(center, 2.5, Color.WHITE, false, 1.5)
			for angle in [0.0, PI * 0.25, PI * 0.5, PI * 0.75, PI, PI * 1.25, PI * 1.5, PI * 1.75]:
				var start := center + Vector2(cos(angle), sin(angle)) * 8.0
				var end := center + Vector2(cos(angle), sin(angle)) * 10.0
				draw_line(start, end, accent, 1.5, true)
		"credits":
			var star := PackedVector2Array()
			for point_index in range(10):
				var angle := -PI * 0.5 + TAU * float(point_index) / 10.0
				var radius := 9.0 if point_index % 2 == 0 else 4.0
				star.append(center + Vector2(cos(angle), sin(angle)) * radius)
			draw_colored_polygon(star, accent)
		"exit":
			draw_rect(Rect2(center + Vector2(-7, -9), Vector2(12, 18)), Color.TRANSPARENT, false, 1.5, true)
			draw_line(center + Vector2(-2, 0), center + Vector2(9, 0), accent, 1.8, true)
			draw_line(center + Vector2(5, -4), center + Vector2(9, 0), accent, 1.8, true)
			draw_line(center + Vector2(5, 4), center + Vector2(9, 0), accent, 1.8, true)
