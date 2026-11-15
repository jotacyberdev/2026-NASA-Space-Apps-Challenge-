extends Control

const WARM_THEME := preload("res://scripts/ui/warm_sci_fi_theme.gd")

const CHARACTER_FEMALE_PATH := "res://assets/sprites/characters/sofia/"
const CHARACTER_MALE_PATH := "res://assets/sprites/characters/male/"
const PET_LAIKA_PATH := "res://assets/sprites/characters/laika/"
const PET_HAM_PATH := "res://assets/sprites/characters/ham/"

var gender := "female"
var pet := "dog"
var idle_time := 0.0

var astro_female_tex: Texture2D
var astro_male_tex: Texture2D
var pet_laika_tex: Texture2D
var pet_ham_tex: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_load_preview_textures()
	queue_redraw()


func _load_preview_textures() -> void:
	astro_female_tex = _extract_first_frame(CHARACTER_FEMALE_PATH + "Frente.png")
	astro_male_tex = _extract_first_frame(CHARACTER_MALE_PATH + "Frente.png")
	pet_laika_tex = _extract_first_frame(PET_LAIKA_PATH + "Parado.png")
	pet_ham_tex = _extract_first_frame(PET_HAM_PATH + "Parado.png")


func _extract_first_frame(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var raw_tex: Texture2D = load(path)
	if raw_tex == null:
		return null
	var w := raw_tex.get_width()
	var h := raw_tex.get_height()
	if w > int(h * 1.5) and h > 0:
		var atlas := AtlasTexture.new()
		atlas.atlas = raw_tex
		atlas.region = Rect2(0, 0, h, h)
		atlas.filter_clip = true
		return atlas
	return raw_tex


func set_selection(new_gender: String, new_pet: String) -> void:
	gender = new_gender
	pet = new_pet
	queue_redraw()


func _process(delta: float) -> void:
	idle_time += delta
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0.0 or h <= 0.0:
		return

	# Fundo espacial e horizonte marciano
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.08, 0.04, 0.02, 1.0))
	var ground_y := h * 0.72
	draw_rect(Rect2(0.0, ground_y, w, h - ground_y), Color(0.45, 0.19, 0.08, 1.0))
	draw_line(Vector2(0.0, ground_y), Vector2(w, ground_y), Color(0.75, 0.36, 0.16, 1.0), 2.0)

	var bob := sin(idle_time * 3.0) * 3.0
	var astro_pos := Vector2(w * 0.38, ground_y + bob)
	var pet_pos := Vector2(w * 0.64, ground_y - bob * 0.8)

	# Desenha Astronauta (Sprite real ou fallback)
	var active_astro := astro_female_tex if gender == "female" else astro_male_tex
	if active_astro != null:
		var astro_size := Vector2(128, 128)
		var astro_rect := Rect2(astro_pos - Vector2(astro_size.x * 0.5, astro_size.y - 6.0), astro_size)
		draw_texture_rect(active_astro, astro_rect, false)
	else:
		_draw_astronaut_fallback(astro_pos)

	# Desenha Mascote (Sprite real ou fallback)
	var active_pet := pet_laika_tex if pet == "dog" else pet_ham_tex
	if active_pet != null:
		var pet_size := Vector2(96, 96)
		var pet_rect := Rect2(pet_pos - Vector2(pet_size.x * 0.5, pet_size.y - 6.0), pet_size)
		draw_texture_rect(active_pet, pet_rect, false)
	else:
		_draw_pet_fallback(pet_pos)


func _draw_astronaut_fallback(base_pos: Vector2) -> void:
	var suit := Color(0.92, 0.45, 0.15, 1.0) if gender == "female" else Color(0.90, 0.90, 0.94, 1.0)
	draw_rect(Rect2(base_pos + Vector2(-18, -68), Vector2(36, 44)), suit)
	draw_circle(base_pos + Vector2(0, -84), 18.0, Color(0.95, 0.95, 0.98, 1.0))
	draw_rect(Rect2(base_pos + Vector2(-11, -90), Vector2(22, 12)), Color(0.98, 0.72, 0.20, 1.0))
	draw_rect(Rect2(base_pos + Vector2(-14, -24), Vector2(10, 24)), Color(0.3, 0.3, 0.35, 1.0))
	draw_rect(Rect2(base_pos + Vector2(4, -24), Vector2(10, 24)), Color(0.3, 0.3, 0.35, 1.0))


func _draw_pet_fallback(base_pos: Vector2) -> void:
	var fur := Color(0.82, 0.65, 0.45, 1.0) if pet == "dog" else Color(0.45, 0.28, 0.16, 1.0)
	draw_rect(Rect2(base_pos + Vector2(-16, -28), Vector2(32, 20)), fur)
	draw_circle(base_pos + Vector2(12, -32), 11.0, fur)
