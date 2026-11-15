extends Node2D

const WARM_THEME := preload("res://scripts/ui/warm_sci_fi_theme.gd")
const ASSET_REGISTRY := preload("res://scripts/core/asset_registry.gd")

# Distinct building sprite paths per structure ID
const BUILDING_SPRITE_PATHS := {
	"habitat": "res://assets/sprites/buildings/habitat_lvl1.png",
	"workshop": "res://assets/sprites/buildings/workshop_lvl1.png",
	"warehouse": "res://assets/sprites/buildings/warehouse_lvl1.png",
	"greenhouse": "res://assets/sprites/buildings/greenhouse_lvl1.png",
	"solar_panel": "res://assets/sprites/buildings/solar_panel_lvl1.png",
	"comm_antenna": "res://assets/sprites/buildings/comm_antenna_lvl1.png",
	"laboratory": "res://assets/sprites/buildings/laboratory_lvl1.png",
	"pet_shelter": "res://assets/sprites/buildings/pet_shelter_lvl1.png",
}

var structure_id := "habitat"
var structure_size := Vector2(150, 100)
var is_built := false
var is_selected := false
var _sprite: Sprite2D

func configure(new_id: String, world_position: Vector2, dimensions: Vector2, built: bool, selected: bool) -> void:
	structure_id = new_id
	position = world_position
	structure_size = dimensions
	is_built = built
	is_selected = selected
	_update_sprite()
	queue_redraw()

func set_state(built: bool, selected: bool) -> void:
	if is_built == built and is_selected == selected:
		return
	is_built = built
	is_selected = selected
	_update_sprite()
	queue_redraw()

func _update_sprite() -> void:
	if is_built and _sprite == null:
		var tex_path = BUILDING_SPRITE_PATHS[structure_id]
		var tex := WARM_THEME.load_texture(tex_path) if tex_path != null else null
		if tex == null:
			tex = ASSET_REGISTRY.building_texture(structure_id)
		if tex != null:
			_sprite = Sprite2D.new()
			_sprite.name = "BuildingSprite"
			_sprite.texture = tex
			_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_sprite.centered = true
			var fit_scale := minf(structure_size.x / float(tex.get_width()), structure_size.y / float(tex.get_height()))
			_sprite.scale = Vector2.ONE * fit_scale
			add_child(_sprite)
	if _sprite != null:
		_sprite.visible = is_built

func _draw() -> void:
	if is_built:
		if _sprite == null:
			_draw_procedural_building()
		return
	if not is_selected:
		return
	_draw_dashed_wireframe()
	_draw_alert_badge()

func _draw_dashed_wireframe() -> void:
	var half := structure_size * 0.5
	var corners := [
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y)
	]
	var color := Color(0.35, 0.82, 0.91, 0.88)
	for edge_index in range(corners.size()):
		var start: Vector2 = corners[edge_index]
		var finish: Vector2 = corners[(edge_index + 1) % corners.size()]
		var edge := finish - start
		var edge_length := edge.length()
		var direction := edge / edge_length
		var dash_count := maxi(2, int(edge_length / 14.0))
		for dash_index in range(dash_count):
			if dash_index % 2 == 0:
				var dash_start := start + direction * edge_length * float(dash_index) / float(dash_count)
				var dash_end := start + direction * edge_length * float(dash_index + 1) / float(dash_count)
				draw_line(dash_start, dash_end, color, 2.0, true)
	var label := "ESTRUTURA NÃO CONSTRUÍDA  |  " + structure_id.replace("_", " ").to_upper()
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(-half.x, half.y + 18.0), label, HORIZONTAL_ALIGNMENT_LEFT, structure_size.x + 80.0, 10, Color("#D8E9EC"))

func _draw_alert_badge() -> void:
	var badge_center := Vector2(structure_size.x * 0.5 - 8.0, -structure_size.y * 0.5 + 8.0)
	draw_circle(badge_center, 10.0, Color("#E58A42"))
	draw_colored_polygon(PackedVector2Array([
		badge_center + Vector2(0, -6), badge_center + Vector2(5, 4), badge_center + Vector2(-5, 4)
	]), Color("#17212A"))
	draw_line(badge_center + Vector2(0, -2), badge_center + Vector2(0, 1), Color("#FFD48A"), 1.5, true)
	draw_circle(badge_center + Vector2(0, 3), 0.8, Color("#FFD48A"))

func _draw_procedural_building() -> void:
	var half := structure_size * 0.5
	var dark := Color(0.12, 0.19, 0.22, 1.0)
	var metal := Color(0.49, 0.61, 0.63, 1.0)
	var accent := Color("#D98746")
	draw_colored_polygon(PackedVector2Array([
		Vector2(-half.x, half.y * 0.36), Vector2(-half.x * 0.78, -half.y * 0.58),
		Vector2(half.x * 0.78, -half.y * 0.58), Vector2(half.x, half.y * 0.36),
		Vector2(half.x * 0.82, half.y), Vector2(-half.x * 0.82, half.y)
	]), metal)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-half.x * 0.82, half.y), Vector2(-half.x * 0.62, 0),
		Vector2(half.x * 0.62, 0), Vector2(half.x * 0.82, half.y)
	]), dark)
	draw_line(Vector2(-half.x * 0.76, half.y * 0.18), Vector2(half.x * 0.76, half.y * 0.18), accent, 4.0, true)
	if structure_id in ["habitat", "greenhouse", "pet_shelter"]:
		draw_arc(Vector2(0, 0), half.x * 0.48, PI, TAU, 32, Color("#91D8DF"), 3.0, true)
		draw_line(Vector2(0, -half.y * 0.50), Vector2(0, half.y * 0.5), Color(0.73, 0.89, 0.87, 0.7), 1.0, true)
	else:
		for window_x in [-0.38, 0.0, 0.38]:
			draw_rect(Rect2(Vector2(half.x * window_x - 6, -half.y * 0.31), Vector2(12, 11)), Color("#55B7C7"), true)
	draw_polyline(PackedVector2Array([
		Vector2(-half.x, half.y * 0.36), Vector2(-half.x * 0.78, -half.y * 0.58),
		Vector2(half.x * 0.78, -half.y * 0.58), Vector2(half.x, half.y * 0.36),
		Vector2(half.x * 0.82, half.y), Vector2(-half.x * 0.82, half.y), Vector2(-half.x, half.y * 0.36)
	]), Color("#D0DDDA"), 1.5, true)
