extends Control

const WARM_THEME := preload("res://scripts/ui/warm_sci_fi_theme.gd")

@onready var name_edit: LineEdit = $CenterContainer/Panel/Margin/VBox/BodyColumns/LeftColumn/NameContainer/NameEdit
@onready var male_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/LeftColumn/GenderContainer/MaleButton
@onready var female_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/LeftColumn/GenderContainer/FemaleButton
@onready var dog_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/RightColumn/PetContainer/DogButton
@onready var monkey_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/RightColumn/PetContainer/MonkeyButton
@onready var easy_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/RightColumn/DifficultyContainer/EasyButton
@onready var normal_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/RightColumn/DifficultyContainer/NormalButton
@onready var hard_button: Button = $CenterContainer/Panel/Margin/VBox/BodyColumns/RightColumn/DifficultyContainer/HardButton
@onready var continue_button: Button = $CenterContainer/Panel/Margin/VBox/Buttons/ContinueButton
@onready var back_button: Button = $CenterContainer/Panel/Margin/VBox/Buttons/BackButton
@onready var error_label: Label = $CenterContainer/Panel/Margin/VBox/BodyColumns/LeftColumn/ErrorLabel
@onready var character_preview: Control = $CenterContainer/Panel/Margin/VBox/BodyColumns/PreviewColumn/CharacterPreview

# Asset paths for real portraits and sprites
const PORTRAIT_FEMALE_PATH := "res://assets/sprites/characters/sofia/Frente.png"
const PORTRAIT_MALE_PATH := "res://assets/sprites/characters/male/Frente.png"
const PORTRAIT_LAIKA_PATH := "res://assets/sprites/characters/laika/Parado.png"
const PORTRAIT_HAM_PATH := "res://assets/sprites/characters/ham/Parado.png"
const ASTRO_FEMALE_WALK_PATH := "res://assets/sprites/characters/astronaut_female_walk_grid.png"
const ASTRO_MALE_WALK_PATH := "res://assets/sprites/characters/astronaut_male_walk_grid.png"
const PET_LAIKA_WALK_PATH := "res://assets/sprites/characters/pet_laika_walk_grid.png"
const PET_HAM_WALK_PATH := "res://assets/sprites/characters/pet_ham_walk_grid.png"

var selected_gender := "female"
var selected_pet := "dog"
var selected_difficulty := "normal"

var portrait_female_tex: Texture2D
var portrait_male_tex: Texture2D
var portrait_laika_tex: Texture2D
var portrait_ham_tex: Texture2D

func _ready() -> void:
	$CenterContainer/Panel.add_theme_stylebox_override("panel", WARM_THEME.panel_style(0.96))
	$CenterContainer/Panel/Margin/VBox.add_theme_constant_override("separation", 14)
	for button in [male_button, female_button, dog_button, monkey_button, easy_button, normal_button, hard_button]:
		_style_selection_button(button)
	WARM_THEME.apply_button(continue_button, true)
	WARM_THEME.apply_button(back_button, false, true)
	_style_line_edit(name_edit)
	_load_portraits()
	_setup_gender_portraits()
	_setup_pet_portraits()
	_select_gender(selected_gender)
	_select_pet(selected_pet)
	_select_difficulty(selected_difficulty)
	name_edit.text = GameManager.player_name if GameManager.player_name != "Astra" else ""
	error_label.text = ""

func _load_portraits() -> void:
	var portrait_female_wp := WARM_THEME.load_texture(PORTRAIT_FEMALE_PATH)
	var portrait_male_wp := WARM_THEME.load_texture(PORTRAIT_MALE_PATH)
	var portrait_laika_wp := WARM_THEME.load_texture(PORTRAIT_LAIKA_PATH)
	var portrait_ham_wp := WARM_THEME.load_texture(PORTRAIT_HAM_PATH)
	
	# Get first frame region for portraits (use first frame if horizontal strip)
	var female_region := Rect2(0, 0, portrait_female_wp.get_height(), portrait_female_wp.get_height())
	var male_region := Rect2(0, 0, portrait_male_wp.get_height(), portrait_male_wp.get_height())
	var laika_region := Rect2(0, 0, portrait_laika_wp.get_height(), portrait_laika_wp.get_height())
	var ham_region := Rect2(0, 0, portrait_ham_wp.get_height(), portrait_ham_wp.get_height())
	
	# Create atlas with region for portraits
	var female_atlas := AtlasTexture.new()
	female_atlas.atlas = portrait_female_wp
	female_atlas.region = female_region
	female_atlas.filter_clip = true

	var male_atlas := AtlasTexture.new()
	male_atlas.atlas = portrait_male_wp
	male_atlas.region = male_region
	male_atlas.filter_clip = true

	var laika_atlas := AtlasTexture.new()
	laika_atlas.atlas = portrait_laika_wp
	laika_atlas.region = laika_region
	laika_atlas.filter_clip = true

	var ham_atlas := AtlasTexture.new()
	ham_atlas.atlas = portrait_ham_wp
	ham_atlas.region = ham_region
	ham_atlas.filter_clip = true

	portrait_female_tex = female_atlas
	portrait_male_tex = male_atlas
	portrait_laika_tex = laika_atlas
	portrait_ham_tex = ham_atlas


func _setup_gender_portraits() -> void:
	var female_portrait := _make_portrait_sprite(portrait_female_tex, "FEMININO")
	female_portrait.name = "FemalePortrait"
	female_button.text = ""
	female_button.add_child(female_portrait)
	var male_portrait := _make_portrait_sprite(portrait_male_tex, "MASCULINO")
	male_portrait.name = "MalePortrait"
	male_button.text = ""
	male_button.add_child(male_portrait)

func _setup_pet_portraits() -> void:
	var laika_portrait := _make_portrait_sprite(portrait_laika_tex, "LAIKA")
	laika_portrait.name = "LaikaPortrait"
	dog_button.add_child(laika_portrait)
	var ham_portrait := _make_portrait_sprite(portrait_ham_tex, "HAM")
	ham_portrait.name = "HamPortrait"
	monkey_button.add_child(ham_portrait)

func _make_portrait_sprite(tex: Texture2D, label_text: String) -> Control:
	var container := VBoxContainer.new()
	container.alignment = 1
	container.add_theme_constant_override("separation", 4)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sprite := TextureRect.new()
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = Vector2(64, 64)
	if tex != null:
		sprite.texture = tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	else:
		sprite.modulate = Color(0.3, 0.2, 0.15, 1)

	# Centralizar o texto abaixo do retrato
	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", WARM_THEME.TEXT_MUTED)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.position = Vector2(0, 70) # Abaixo do retrato
	container.add_child(sprite)
	container.add_child(name_label)
	return container

func _style_line_edit(edit: LineEdit) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.04, 0.03, 0.95)
	normal.border_color = WARM_THEME.COPPER
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(8)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.border_color = WARM_THEME.AMBER
	focus.set_border_width_all(2)
	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", WARM_THEME.TEXT)
	edit.add_theme_color_override("placeholder_color", WARM_THEME.TEXT_MUTED)

func _select_gender(value: String) -> void:
	selected_gender = value
	male_button.button_pressed = value == "male"
	female_button.button_pressed = value == "female"
	_refresh_preview()

func _select_pet(value: String) -> void:
	selected_pet = value
	dog_button.button_pressed = value == "dog"
	monkey_button.button_pressed = value == "monkey"
	_refresh_preview()

func _select_difficulty(value: String) -> void:
	selected_difficulty = value
	easy_button.button_pressed = value == "easy"
	normal_button.button_pressed = value == "normal"
	hard_button.button_pressed = value == "hard"

func _refresh_preview() -> void:
	if is_instance_valid(character_preview):
		character_preview.call("set_selection", selected_gender, selected_pet)

func _style_selection_button(button: Button) -> void:
	var idle := StyleBoxFlat.new()
	idle.bg_color = Color(0.09, 0.05, 0.036, 0.9)
	idle.border_color = Color(0.55, 0.29, 0.14, 0.8)
	idle.set_border_width_all(1)
	idle.set_corner_radius_all(4)
	idle.set_content_margin_all(8)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.19, 0.09, 0.045, 0.96)
	hover.border_color = Color("#FF9E2C")
	hover.set_border_width_all(1)
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(8)
	var selected := StyleBoxFlat.new()
	selected.bg_color = Color("#A94416")
	selected.border_color = Color("#FFB647")
	selected.set_border_width_all(2)
	selected.set_corner_radius_all(4)
	selected.set_content_margin_all(7)
	button.add_theme_stylebox_override("normal", idle)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", selected)
	button.add_theme_color_override("font_color", Color("#E8D8C8"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)

func _on_gender_male_pressed() -> void:
	_select_gender("male")

func _on_gender_female_pressed() -> void:
	_select_gender("female")

func _on_pet_dog_pressed() -> void:
	_select_pet("dog")

func _on_pet_monkey_pressed() -> void:
	_select_pet("monkey")

func _on_difficulty_easy_pressed() -> void:
	_select_difficulty("easy")

func _on_difficulty_normal_pressed() -> void:
	_select_difficulty("normal")

func _on_difficulty_hard_pressed() -> void:
	_select_difficulty("hard")

func _on_continue_pressed() -> void:
	var cleaned_name := name_edit.text.strip_edges()
	if cleaned_name.length() < 2 or cleaned_name.length() > 16:
		error_label.text = "O nome deve ter entre 2 e 16 caracteres."
		return

	if cleaned_name.is_empty():
		error_label.text = "Informe um nome para continuar."
		return

	name_edit.text = cleaned_name
	GameManager.begin_new_game(cleaned_name, selected_gender, selected_pet, selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/story/introduction.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
