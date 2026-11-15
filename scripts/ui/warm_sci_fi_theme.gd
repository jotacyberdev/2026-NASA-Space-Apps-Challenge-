class_name WarmSciFiTheme
extends RefCounted

const PANEL := Color(0.11, 0.06, 0.04, 0.92)
const PANEL_DEEP := Color(0.055, 0.032, 0.027, 0.97)
const COPPER := Color("#E86A17")
const AMBER := Color("#FF9E2C")
const AMBER_LIGHT := Color("#FFD27B")
const TEXT := Color("#F4EEE6")
const TEXT_MUTED := Color("#C9B6A2")
const SUCCESS := Color("#9BCB79")
const DANGER := Color("#E66F57")

# Radar and Map Colors
const MAP_BG := Color(0.08, 0.04, 0.03, 1.0)
const MAP_GRID := Color(0.91, 0.42, 0.12, 0.15)
const MAP_ACCENT := Color("#FF9E2C")
const MAP_PLAYER := Color("#F4EEE6")

static func panel_style(alpha: float = 0.92) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.06, 0.04, alpha)
	style.border_color = COPPER
	style.set_border_width_all(1)
	style.border_width_top = 2
	style.border_width_left = 2
	style.set_corner_radius_all(4)
	style.set_content_margin_all(12)
	style.shadow_color = Color(0.02, 0.008, 0.004, 0.45)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	return style

static func badge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.12, 0.08, 1.0)
	style.border_color = COPPER
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 5
	style.content_margin_right = 5
	return style

static func load_texture(path: String) -> Texture2D:
	var tex := load(path) as Texture2D
	return tex

static func apply_button(button: Button, primary: bool = false, compact: bool = false) -> void:
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()
	var disabled := StyleBoxFlat.new()
	if primary:
		normal.bg_color = Color("#D95B16")
		normal.border_color = AMBER
		hover.bg_color = Color("#FF8C24")
		hover.border_color = Color("#FFD27B")
		pressed.bg_color = Color("#A84110")
		pressed.border_color = COPPER
	else:
		normal.bg_color = Color(0.105, 0.058, 0.04, 0.94)
		normal.border_color = Color(0.91, 0.39, 0.09, 0.82)
		hover.bg_color = Color(0.21, 0.10, 0.052, 0.98)
		hover.border_color = AMBER
		pressed.bg_color = Color(0.12, 0.052, 0.03, 1.0)
		pressed.border_color = COPPER
	disabled.bg_color = Color(0.09, 0.07, 0.06, 0.82)
	disabled.border_color = Color(0.38, 0.29, 0.22, 0.58)
	for style in [normal, hover, pressed, disabled]:
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		style.set_content_margin_all(7 if compact else 10)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color.WHITE if primary else TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#FFE0B6"))
	button.add_theme_color_override("font_disabled_color", Color(0.61, 0.54, 0.47, 0.78))
	button.add_theme_font_size_override("font_size", 14 if compact else 16)
