extends Control

const PAGES: Array = [
	{
		"title": "Missão em Marte",
		"text": "A astronauta foi enviada para uma base de pesquisa marciana. Seu objetivo é estabilizar o acampamento e sobreviver ao primeiro dia no planeta vermelho."
	},
	{
		"title": "Tempestade de poeira",
		"text": "Uma tempestade intensa atingiu a nave e comprometeu os sistemas de estabilização. O impacto reduz a visibilidade e coloca a missão em risco."
	},
	{
		"title": "Nave em queda",
		"text": "Os destroços da nave caíram em uma região próxima ao acampamento. Materiais e equipamentos ainda podem ser recuperados."
	},
	{
		"title": "Acordar perto dos destroços",
		"text": "A astronauta desperta ferida, mas viva. O tutorial do dia 1 começa com a recuperação do acampamento e a sobrevivência inicial."
	}
]

@onready var title_label: Label = $Background/Panel/Margin/Content/TitleLabel
@onready var body_label: Label = $Background/Panel/Margin/Content/BodyLabel
@onready var page_label: Label = $Background/Panel/Margin/Content/PageLabel
@onready var illustration: Control = $Background/Panel/Margin/Content/IllustrationPanel
@onready var continue_button: Button = $Background/Panel/Margin/Content/Controls/ContinueButton
@onready var skip_button: Button = $Background/Panel/Margin/Content/Controls/SkipButton

var current_page := 0

func _ready() -> void:
	_style_story_button(continue_button, true)
	_style_story_button(skip_button, false)
	page_label.add_theme_color_override("font_color", Color("#75D4DF"))
	current_page = 0
	update_page()

func update_page() -> void:
	var page = PAGES[current_page]
	title_label.text = page["title"]
	body_label.text = page["text"]
	illustration.call("set_slide", current_page)
	page_label.text = str(current_page + 1) + "/" + str(PAGES.size())
	continue_button.text = "Continuar" if current_page < PAGES.size() - 1 else "Iniciar Dia 1"

func _style_story_button(button: Button, is_primary: bool) -> void:
	var normal := StyleBoxFlat.new()
	var hover := StyleBoxFlat.new()
	var pressed := StyleBoxFlat.new()
	if is_primary:
		normal.bg_color = Color("#B9572B")
		normal.border_color = Color("#F3A24D")
		hover.bg_color = Color("#E37339")
		hover.border_color = Color("#FFD18A")
		pressed.bg_color = Color("#93401F")
		pressed.border_color = Color("#E78945")
	else:
		normal.bg_color = Color(0.04, 0.075, 0.11, 0.78)
		normal.border_color = Color(0.31, 0.47, 0.55, 0.58)
		hover.bg_color = Color(0.08, 0.15, 0.19, 0.96)
		hover.border_color = Color(0.38, 0.71, 0.77, 0.86)
		pressed.bg_color = Color(0.035, 0.10, 0.14, 1.0)
		pressed.border_color = Color(0.25, 0.58, 0.65, 0.94)
	for style in [normal, hover, pressed]:
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.set_content_margin_all(7)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#FFF3E3") if is_primary else Color("#BCCBD0"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_font_size_override("font_size", 15 if is_primary else 13)

func _on_continue_pressed() -> void:
	if current_page < PAGES.size() - 1:
		current_page += 1
		update_page()
	else:
		GameManager.intro_skipped = false
		GameManager.save_game()
		get_tree().change_scene_to_file("res://scenes/world/mars_base.tscn")

func _on_skip_pressed() -> void:
	GameManager.intro_skipped = true
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/world/mars_base.tscn")
