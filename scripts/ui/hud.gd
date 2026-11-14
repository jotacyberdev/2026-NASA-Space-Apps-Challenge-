extends CanvasLayer

signal expedition_begin_requested
signal modal_visibility_changed(modal_visible: bool)
signal construction_preview_changed(structure_id: String)

@onready var name_label: Label = $TopLeftPanel/MarginContainer/HBoxContainer/InfoContainer/NameLabel
@onready var portrait: Control = $TopLeftPanel/MarginContainer/HBoxContainer/Portrait
@onready var crew_label: Label = $TopLeftPanel/MarginContainer/HBoxContainer/InfoContainer/CrewLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var oxygen_bar: ProgressBar = %OxygenBar
@onready var energy_bar: ProgressBar = %EnergyBar
@onready var hunger_bar: ProgressBar = %HungerBar
@onready var water_bar: ProgressBar = %WaterBar
@onready var objective_label: Label = $ObjectivePanel/MarginContainer/ObjectiveLabel
@onready var day_label: Label = $TopRightPanel/MarginContainer/ClockContent/DayLabel
@onready var time_label: Label = $TopRightPanel/MarginContainer/ClockContent/ClockRow/TimeLabel
@onready var sol_label: Label = $TopRightPanel/MarginContainer/ClockContent/ClockRow/SolLabel

const QUICKBAR_ICON_SCRIPT := preload("res://scripts/ui/quickbar_icon.gd")
const MARS_RADAR_SCRIPT := preload("res://scripts/ui/mars_radar.gd")
const QUICKBAR_ITEMS := ["rations", "water_bottle", "medkit", "metal", "polymer", "seeds"]
const QUICKBAR_LABELS := ["Ração", "Água", "Kit médico", "Metal", "Polímero", "Sementes"]
const ITEM_DESCRIPTIONS := {
	"metal": "Material recuperado para estruturas básicas.",
	"polymer": "Material leve usado na construção do habitat e da estufa.",
	"seeds": "Sementes reservadas para iniciar a estufa.",
	"rations": "Recupera 30 pontos de fome ao consumir uma unidade.",
	"water_bottle": "Recupera 30 pontos de água ao consumir uma unidade.",
	"medkit": "Recupera 25 pontos de vida ao consumir uma unidade.",
	"spare_parts": "Componentes recuperados durante a exploração do rover."
}
const ITEM_EFFECTS := {
	"rations": "EFEITO  |  +30 FOME",
	"water_bottle": "EFEITO  |  +30 ÁGUA",
	"medkit": "EFEITO  |  +25 VIDA",
	"metal": "RECURSO  |  Usado na construção de estruturas.",
	"polymer": "RECURSO  |  Usado no habitat e na estufa.",
	"seeds": "RECURSO  |  Necessário para iniciar a estufa.",
	"spare_parts": "RECURSO  |  Necessário para a mineradora."
}
const SCIENCE_ENTRIES := [
	{
		"id": "atmosphere",
		"title": "Atmosfera marciana",
		"category": "Atmosfera",
		"text": "A atmosfera de Marte é fina e composta principalmente por dióxido de carbono, nitrogênio e argônio. Ela oferece pouca proteção e não é respirável por humanos.",
		"source": "https://science.nasa.gov/mars/facts/"
	},
	{
		"id": "moxie",
		"title": "Oxigênio e MOXIE",
		"category": "Tecnologia",
		"text": "O experimento MOXIE, a bordo do rover Perseverance, demonstrou a produção de oxigênio a partir do dióxido de carbono da atmosfera marciana.",
		"source": "https://science.nasa.gov/mission/mars-2020-perseverance/science-instruments/"
	},
	{
		"id": "water",
		"title": "Água em Marte",
		"category": "Recursos",
		"text": "Marte preserva evidências geológicas de um passado mais úmido. Atualmente, água é encontrada principalmente como gelo, inclusive sob a superfície em regiões polares.",
		"source": "https://science.nasa.gov/mars/facts/"
	},
	{
		"id": "dust_storms",
		"title": "Tempestades de poeira",
		"category": "Clima",
		"text": "Ventos podem levantar poeira e formar tempestades que cobrem grandes áreas do planeta. Depois de algumas tempestades, a poeira pode levar meses para se depositar.",
		"source": "https://science.nasa.gov/mars/facts/"
	},
	{
		"id": "regolith_perchlorate",
		"title": "Regolito e percloratos",
		"category": "Solo",
		"text": "A missão Phoenix detectou perclorato em amostras do solo marciano. A NASA descreve o composto como potencial recurso para futuras explorações; sua presença não é evidência de vida.",
		"source": "https://science.nasa.gov/mission/phoenix/"
	},
	{
		"id": "space_crops",
		"title": "Estufa e cultivo",
		"category": "Cultivo",
		"text": "A instalação Veggie da NASA na Estação Espacial Internacional permite cultivar plantas em microgravidade e estudar o crescimento vegetal em missões espaciais.",
		"source": "https://www.nasa.gov/mission/station/research-explorer/experiment/veggie/"
	}
]

var overlay: PanelContainer
var modal_backdrop: ColorRect
var overlay_title: Label
var overlay_body: Label
var inventory_section: HBoxContainer
var inventory_grid: GridContainer
var inventory_detail: PanelContainer
var inventory_detail_title: Label
var inventory_detail_description: Label
var inventory_detail_effect: Label
var inventory_use_button: Button
var choice_scroll: ScrollContainer
var choice_container: VBoxContainer
var map_radar: Control
var interaction_prompt: PanelContainer
var interaction_prompt_label: Label
var inventory_buttons: Array[Button] = []
var inventory_item_labels: Array[Label] = []
var inventory_count_labels: Array[Label] = []
var inventory_icon_controls: Array[Control] = []
var quickbar_item_labels: Array[Label] = []
var quickbar_count_labels: Array[Label] = []
var selected_inventory_slot := -1

func _ready() -> void:
	assert(is_instance_valid(health_bar), "HUD: Scene Unique Node '%HealthBar' não foi encontrado.")
	assert(is_instance_valid(oxygen_bar), "HUD: Scene Unique Node '%OxygenBar' não foi encontrado.")
	assert(is_instance_valid(energy_bar), "HUD: Scene Unique Node '%EnergyBar' não foi encontrado.")
	assert(is_instance_valid(hunger_bar), "HUD: Scene Unique Node '%HungerBar' não foi encontrado.")
	assert(is_instance_valid(water_bar), "HUD: Scene Unique Node '%WaterBar' não foi encontrado.")
	_apply_hud_theme()
	_setup_quickbar()
	_add_vignette()
	GameManager.state_changed.connect(update_hud)
	$BottomLeftPanel/MarginContainer/Buttons/InventoryButton.pressed.connect(open_inventory)
	$BottomLeftPanel/MarginContainer/Buttons/ConstructionButton.pressed.connect(open_construction)
	$BottomLeftPanel/MarginContainer/Buttons/MapButton.pressed.connect(open_map)
	$BottomLeftPanel/MarginContainer/Buttons/JournalButton.pressed.connect(open_journal)
	$BottomLeftPanel/MarginContainer/Buttons/SettingsButton.pressed.connect(open_settings)
	_build_overlay()
	for index in range(6):
		var quickbar_button: Button = get_node("QuickBar/MarginContainer/HBoxContainer/Slot%d" % (index + 1))
		quickbar_button.pressed.connect(_on_quickbar_pressed.bind(index))
	update_hud()
	_update_inventory_view()

func _apply_hud_theme() -> void:
	var panel_style := _make_panel_style()
	for panel_path in ["TopLeftPanel", "ObjectivePanel", "TopRightPanel", "BottomLeftPanel", "QuickBar"]:
		var panel := get_node_or_null(panel_path) as PanelContainer
		assert(is_instance_valid(panel), "HUD: painel essencial '%s' não foi encontrado." % panel_path)
		panel.add_theme_stylebox_override("panel", panel_style.duplicate())
	for node in find_children("*", "Button", true, false):
		_style_button(node as Button)
	_style_progress_bar(health_bar, Color("#E63946"))
	_style_progress_bar(oxygen_bar, Color("#00B4D8"))
	_style_progress_bar(energy_bar, Color("#FFB703"))
	_style_progress_bar(hunger_bar, Color("#FB8500"))
	_style_progress_bar(water_bar, Color("#3A86FF"))
	for stat_name in ["Health", "Oxygen", "Energy", "Hunger", "Water"]:
		var stat_label := get_node("TopLeftPanel/MarginContainer/HBoxContainer/InfoContainer/StatsContainer/%sRow/%sLabel" % [stat_name, stat_name]) as Label
		stat_label.custom_minimum_size.x = 80
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color("#F3F7FA"))
	crew_label.add_theme_font_size_override("font_size", 9)
	crew_label.add_theme_color_override("font_color", Color("#70D8E8"))
	objective_label.add_theme_color_override("font_color", Color("#E6EDF3"))
	day_label.add_theme_color_override("font_color", Color("#70D8E8"))
	day_label.add_theme_font_size_override("font_size", 9)
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 24)
	time_label.add_theme_color_override("font_color", Color("#F3F7FA"))
	sol_label.add_theme_font_size_override("font_size", 11)
	sol_label.add_theme_color_override("font_color", Color("#FFB703"))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TopRightPanel/MarginContainer/ClockContent.add_theme_constant_override("separation", 1)
	$TopRightPanel/MarginContainer/ClockContent/ClockRow.add_theme_constant_override("separation", 7)
	$TopRightPanel/MarginContainer/ClockContent/ClockRow.alignment = BoxContainer.ALIGNMENT_CENTER
	$QuickBar/MarginContainer/HBoxContainer.add_theme_constant_override("separation", 8)
	$BottomLeftPanel/MarginContainer/Buttons.add_theme_constant_override("separation", 5)
	$TopLeftPanel/MarginContainer/HBoxContainer.add_theme_constant_override("separation", 12)
	$TopLeftPanel/MarginContainer/HBoxContainer/InfoContainer.add_theme_constant_override("separation", 5)
	$TopLeftPanel/MarginContainer/HBoxContainer/InfoContainer/StatsContainer.add_theme_constant_override("separation", 3)

func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.82)
	style.border_color = Color(0.25, 0.55, 0.85, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(10)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 3)
	return style

func _make_prompt_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.075, 0.095, 0.9)
	style.border_color = Color(0.20, 0.72, 0.82, 0.78)
	style.set_border_width_all(1)
	style.border_width_left = 3
	style.set_corner_radius_all(5)
	style.set_content_margin_all(9)
	return style

func _style_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.13, 0.18, 0.94)
	normal.border_color = Color(0.24, 0.48, 0.63, 0.7)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.12, 0.23, 0.29, 0.98)
	hover.border_color = Color(0.30, 0.78, 0.89, 0.95)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.05, 0.18, 0.23, 1.0)
	pressed.border_color = Color(0.18, 0.78, 0.86, 1.0)
	for style in [normal, hover, pressed]:
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		style.set_content_margin_all(5)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#EAF2F7"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#70D8E8"))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.61, 0.66, 0.65))

func _style_inventory_slot(button: Button, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.065, 0.105, 0.14, 0.94)
	normal.border_color = Color(0.24, 0.43, 0.52, 0.62)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.09, 0.17, 0.21, 0.98)
	hover.border_color = Color(0.32, 0.77, 0.86, 0.92)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.07, 0.20, 0.23, 1.0)
	pressed.border_color = Color(0.26, 0.82, 0.88, 1.0)
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = Color(0.08, 0.18, 0.22, 1.0)
	selected_style.border_color = Color(0.35, 0.83, 0.89, 1.0)
	for style in [normal, hover, pressed, selected_style]:
		style.set_border_width_all(1)
		style.set_corner_radius_all(5)
		style.set_content_margin_all(4)
	button.add_theme_stylebox_override("normal", selected_style if selected else normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)

func _style_choice_card(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.065, 0.10, 0.14, 0.95)
	normal.border_color = Color(0.20, 0.43, 0.56, 0.68)
	normal.border_width_left = 3
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.085, 0.15, 0.19, 0.99)
	hover.border_color = Color(0.27, 0.72, 0.82, 0.96)
	hover.border_width_left = 3
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.055, 0.075, 0.09, 0.82)
	disabled.border_color = Color(0.25, 0.31, 0.34, 0.55)
	disabled.border_width_left = 3
	for style in [normal, hover, disabled]:
		style.set_border_width_all(1)
		style.border_width_left = 3
		style.set_corner_radius_all(5)
		style.set_content_margin_all(12)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_disabled_color", Color("#9AAAB0"))

func _style_progress_bar(bar: ProgressBar, fill_color: Color) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.015, 0.03, 0.045, 0.96)
	background.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_color_override("font_color", Color.WHITE)

func _setup_quickbar() -> void:
	for index in range(6):
		var button := get_node("QuickBar/MarginContainer/HBoxContainer/Slot%d" % (index + 1)) as Button
		button.text = ""
		button.custom_minimum_size = Vector2(108, 76)
		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 3)
		margin.add_theme_constant_override("margin_top", 3)
		margin.add_theme_constant_override("margin_right", 3)
		margin.add_theme_constant_override("margin_bottom", 3)
		var content := VBoxContainer.new()
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_theme_constant_override("separation", 1)
		margin.add_child(content)
		var key_badge_panel := PanelContainer.new()
		key_badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		key_badge_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var badge_style := StyleBoxFlat.new()
		badge_style.bg_color = Color(0.035, 0.13, 0.17, 1.0)
		badge_style.border_color = Color(0.22, 0.62, 0.71, 0.78)
		badge_style.set_border_width_all(1)
		badge_style.set_corner_radius_all(3)
		badge_style.content_margin_left = 5
		badge_style.content_margin_right = 5
		badge_style.content_margin_top = 1
		badge_style.content_margin_bottom = 1
		key_badge_panel.add_theme_stylebox_override("panel", badge_style)
		var key_badge := Label.new()
		key_badge.text = "[%d]" % (index + 1)
		key_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_badge.add_theme_font_size_override("font_size", 9)
		key_badge.add_theme_color_override("font_color", Color("#70D8E8"))
		key_badge_panel.add_child(key_badge)
		content.add_child(key_badge_panel)
		var icon_frame := CenterContainer.new()
		icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.custom_minimum_size.y = 20
		var item_icon := Control.new()
		item_icon.set_script(QUICKBAR_ICON_SCRIPT)
		item_icon.set("item_id", QUICKBAR_ITEMS[index])
		item_icon.custom_minimum_size = Vector2(28, 20)
		item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(item_icon)
		content.add_child(icon_frame)
		var item_label := Label.new()
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		item_label.add_theme_font_size_override("font_size", 11)
		item_label.add_theme_color_override("font_color", Color("#F3F7FA"))
		item_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
		content.add_child(item_label)
		var count_label := Label.new()
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.add_theme_color_override("font_color", Color("#FFD27A"))
		content.add_child(count_label)
		button.add_child(margin)
		quickbar_item_labels.append(item_label)
		quickbar_count_labels.append(count_label)

func _add_vignette() -> void:
	var vignette := ColorRect.new()
	vignette.name = "AtmosphereVignette"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vignette.z_index = -10
	var material := ShaderMaterial.new()
	material.shader = preload("res://shaders/screen_vignette.gdshader")
	vignette.material = material
	add_child(vignette)

func _build_overlay() -> void:
	modal_backdrop = ColorRect.new()
	modal_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_backdrop.color = Color(0.02, 0.025, 0.03, 0.55)
	modal_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	modal_backdrop.z_index = 19
	modal_backdrop.hide()
	add_child(modal_backdrop)
	overlay = PanelContainer.new()
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.offset_left = -520
	overlay.offset_top = -310
	overlay.offset_right = 520
	overlay.offset_bottom = 310
	overlay.z_index = 20
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var modal_style := StyleBoxFlat.new()
	modal_style.bg_color = Color(0.05, 0.07, 0.11, 0.94)
	modal_style.border_color = Color(0.25, 0.55, 0.85, 0.6)
	modal_style.set_border_width_all(1)
	modal_style.set_corner_radius_all(8)
	modal_style.set_content_margin_all(20)
	modal_style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	modal_style.shadow_size = 14
	modal_style.shadow_offset = Vector2(0, 5)
	overlay.add_theme_stylebox_override("panel", modal_style)
	overlay.hide()
	add_child(overlay)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	overlay.add_child(content)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	content.add_child(header)
	overlay_title = Label.new()
	overlay_title.add_theme_font_size_override("font_size", 24)
	overlay_title.add_theme_color_override("font_color", Color("#EAF4F6"))
	overlay_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(overlay_title)
	var close_button := Button.new()
	close_button.text = "[X] Fechar"
	close_button.custom_minimum_size = Vector2(112, 36)
	_style_button(close_button)
	var close_hover := StyleBoxFlat.new()
	close_hover.bg_color = Color(0.31, 0.10, 0.13, 0.98)
	close_hover.border_color = Color(0.92, 0.35, 0.39, 0.95)
	close_hover.set_border_width_all(1)
	close_hover.set_corner_radius_all(4)
	close_hover.set_content_margin_all(5)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_color_override("font_hover_color", Color("#FFD9D9"))
	close_button.pressed.connect(_close_overlay)
	header.add_child(close_button)
	var divider := ColorRect.new()
	divider.custom_minimum_size.y = 1
	divider.color = Color(0.25, 0.55, 0.85, 0.42)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(divider)
	overlay_body = Label.new()
	overlay_body.add_theme_font_size_override("font_size", 13)
	overlay_body.add_theme_color_override("font_color", Color("#AFC4CE"))
	overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_body.hide()
	content.add_child(overlay_body)
	inventory_section = HBoxContainer.new()
	inventory_section.add_theme_constant_override("separation", 14)
	inventory_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_section.hide()
	content.add_child(inventory_section)
	inventory_grid = GridContainer.new()
	inventory_grid.columns = 6
	inventory_grid.custom_minimum_size = Vector2(600, 400)
	inventory_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_grid.add_theme_constant_override("h_separation", 8)
	inventory_grid.add_theme_constant_override("v_separation", 8)
	inventory_section.add_child(inventory_grid)
	inventory_detail = PanelContainer.new()
	inventory_detail.custom_minimum_size.x = 270
	inventory_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_detail.add_theme_stylebox_override("panel", _make_panel_style())
	inventory_section.add_child(inventory_detail)
	var detail_content := VBoxContainer.new()
	detail_content.add_theme_constant_override("separation", 10)
	inventory_detail.add_child(detail_content)
	inventory_detail_title = Label.new()
	inventory_detail_title.add_theme_font_size_override("font_size", 18)
	inventory_detail_title.add_theme_color_override("font_color", Color("#EAF4F6"))
	inventory_detail_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_content.add_child(inventory_detail_title)
	inventory_detail_description = Label.new()
	inventory_detail_description.add_theme_color_override("font_color", Color("#C0D0D6"))
	inventory_detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_content.add_child(inventory_detail_description)
	inventory_detail_effect = Label.new()
	inventory_detail_effect.add_theme_color_override("font_color", Color("#70D8E8"))
	inventory_detail_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_content.add_child(inventory_detail_effect)
	var detail_spacer := Control.new()
	detail_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_content.add_child(detail_spacer)
	inventory_use_button = Button.new()
	inventory_use_button.text = "Usar Item"
	inventory_use_button.custom_minimum_size.y = 40
	_style_button(inventory_use_button)
	inventory_use_button.pressed.connect(_on_inventory_use_pressed)
	detail_content.add_child(inventory_use_button)
	choice_scroll = ScrollContainer.new()
	choice_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	choice_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_scroll.custom_minimum_size.y = 390
	choice_scroll.hide()
	content.add_child(choice_scroll)
	choice_container = VBoxContainer.new()
	choice_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_container.add_theme_constant_override("separation", 8)
	choice_scroll.add_child(choice_container)
	map_radar = Control.new()
	map_radar.set_script(MARS_RADAR_SCRIPT)
	map_radar.custom_minimum_size = Vector2(0, 430)
	map_radar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_radar.hide()
	content.add_child(map_radar)
	for slot_index in range(GameManager.INVENTORY_CAPACITY):
		var slot_button := Button.new()
		slot_button.custom_minimum_size = Vector2(94, 94)
		_style_inventory_slot(slot_button, false)
		slot_button.pressed.connect(_on_inventory_slot_pressed.bind(slot_index))
		var slot_margin := MarginContainer.new()
		slot_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for side in ["left", "top", "right", "bottom"]:
			slot_margin.add_theme_constant_override("margin_" + side, 5)
		var slot_content := VBoxContainer.new()
		slot_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_content.alignment = BoxContainer.ALIGNMENT_CENTER
		slot_content.add_theme_constant_override("separation", 3)
		slot_margin.add_child(slot_content)
		var icon_frame := CenterContainer.new()
		icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.custom_minimum_size.y = 24
		var item_icon := Control.new()
		item_icon.set_script(QUICKBAR_ICON_SCRIPT)
		item_icon.custom_minimum_size = Vector2(32, 24)
		item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_frame.add_child(item_icon)
		slot_content.add_child(icon_frame)
		var item_label := Label.new()
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.add_theme_font_size_override("font_size", 10)
		item_label.add_theme_color_override("font_color", Color("#EAF4F6"))
		item_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		slot_content.add_child(item_label)
		var count_label := Label.new()
		count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 11)
		count_label.add_theme_color_override("font_color", Color("#70D8E8"))
		var quantity_badge := PanelContainer.new()
		quantity_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		quantity_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var quantity_style := StyleBoxFlat.new()
		quantity_style.bg_color = Color(0.035, 0.13, 0.17, 0.92)
		quantity_style.border_color = Color(0.22, 0.62, 0.71, 0.68)
		quantity_style.set_border_width_all(1)
		quantity_style.set_corner_radius_all(3)
		quantity_style.content_margin_left = 5
		quantity_style.content_margin_right = 5
		quantity_style.content_margin_top = 0
		quantity_style.content_margin_bottom = 0
		quantity_badge.add_theme_stylebox_override("panel", quantity_style)
		quantity_badge.add_child(count_label)
		slot_content.add_child(quantity_badge)
		slot_button.add_child(slot_margin)
		inventory_buttons.append(slot_button)
		inventory_item_labels.append(item_label)
		inventory_count_labels.append(count_label)
		inventory_icon_controls.append(item_icon)
		inventory_grid.add_child(slot_button)
	interaction_prompt = PanelContainer.new()
	interaction_prompt.name = "InteractionPrompt"
	interaction_prompt.set_anchors_preset(Control.PRESET_CENTER_TOP)
	interaction_prompt.offset_left = -190
	interaction_prompt.offset_top = 54
	interaction_prompt.offset_right = 190
	interaction_prompt.offset_bottom = 96
	interaction_prompt.custom_minimum_size = Vector2(380, 42)
	interaction_prompt.add_theme_stylebox_override("panel", _make_prompt_style())
	interaction_prompt.hide()
	interaction_prompt_label = Label.new()
	interaction_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interaction_prompt_label.add_theme_color_override("font_color", Color("#EAF2F7"))
	interaction_prompt_label.add_theme_font_size_override("font_size", 16)
	interaction_prompt.add_child(interaction_prompt_label)
	add_child(interaction_prompt)

func _set_overlay_visible(overlay_visible: bool) -> void:
	if not overlay_visible:
		construction_preview_changed.emit("")
	if overlay.visible == overlay_visible:
		return
	modal_backdrop.visible = overlay_visible
	overlay.visible = overlay_visible
	modal_visibility_changed.emit(overlay_visible)

func _resize_overlay(panel_width: float, panel_height: float) -> void:
	overlay.offset_left = -panel_width * 0.5
	overlay.offset_top = -panel_height * 0.5
	overlay.offset_right = panel_width * 0.5
	overlay.offset_bottom = panel_height * 0.5

func _close_overlay() -> void:
	_set_overlay_visible(false)

func show_choices(title: String, message: String, choices: Array[Dictionary]) -> void:
	var has_choices := not choices.is_empty()
	var choice_height := mini(420, choices.size() * 92)
	_resize_overlay(980.0 if has_choices else 760.0, clampf(250.0 + float(choice_height), 320.0, 620.0))
	overlay_title.text = title.to_upper()
	overlay_body.text = message
	overlay_body.show()
	inventory_section.hide()
	choice_scroll.visible = has_choices
	choice_scroll.custom_minimum_size.y = float(choice_height) if has_choices else 0.0
	map_radar.hide()
	_clear_choices()
	for choice in choices:
		_add_choice(choice)
	_set_overlay_visible(true)

func _clear_choices() -> void:
	construction_preview_changed.emit("")
	for child in choice_container.get_children():
		child.queue_free()

func _add_choice(choice: Dictionary) -> void:
	var button := Button.new()
	button.text = ""
	button.disabled = not bool(choice.get("enabled", true))
	button.custom_minimum_size.y = 82
	_style_choice_card(button)
	var card_margin := MarginContainer.new()
	card_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "top", "right", "bottom"]:
		card_margin.add_theme_constant_override("margin_" + side, 12)
	var card_content := VBoxContainer.new()
	card_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_content.add_theme_constant_override("separation", 4)
	card_margin.add_child(card_content)
	var title_label := Label.new()
	title_label.text = str(choice.get("title", choice.get("label", "Continuar"))).to_upper()
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color("#EAF4F6"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_content.add_child(title_label)
	var description_text := str(choice.get("description", ""))
	if not description_text.is_empty():
		var description_label := Label.new()
		description_label.text = description_text
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description_label.add_theme_font_size_override("font_size", 12)
		description_label.add_theme_color_override("font_color", Color("#B8C9D0"))
		description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_content.add_child(description_label)
	var resources: Array = choice.get("resources", [])
	if not resources.is_empty():
		var resource_row := HBoxContainer.new()
		resource_row.add_theme_constant_override("separation", 14)
		resource_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for resource in resources:
			var item_id := str(resource.get("id", ""))
			var required := int(resource.get("amount", 0))
			var available := GameManager.get_item_count(item_id)
			var resource_label := Label.new()
			resource_label.text = "%s  %d/%d" % [GameManager.ITEM_NAMES.get(item_id, item_id), available, required]
			resource_label.add_theme_font_size_override("font_size", 11)
			resource_label.add_theme_color_override("font_color", Color("#76D89B") if available >= required else Color("#F07C78"))
			resource_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			resource_row.add_child(resource_label)
		card_content.add_child(resource_row)
	button.add_child(card_margin)
	button.pressed.connect(_run_choice.bind(choice.get("action", Callable())))
	var preview_id := str(choice.get("preview", ""))
	if not preview_id.is_empty():
		button.mouse_entered.connect(_on_construction_choice_focused.bind(preview_id))
		button.focus_entered.connect(_on_construction_choice_focused.bind(preview_id))
	choice_container.add_child(button)

func _on_construction_choice_focused(structure_id: String) -> void:
	construction_preview_changed.emit(structure_id)

func _run_choice(action: Callable) -> void:
	_close_overlay()
	if action.is_valid():
		action.call()

func _show_notice(title: String, message: String) -> void:
	show_choices(title, message, [])

func on_world_interaction(object_id: String) -> void:
	match object_id:
		"cache":
			if GameManager.collect_initial_cache():
				_show_notice("Suprimentos recuperados", "Materiais, ração, água e um kit médico foram adicionados à mochila.")
			elif not GameManager.cache_opened:
				_show_notice("Mochila cheia", "Libere espaço antes de recolher os suprimentos.")
			else:
				_show_notice("Baú vazio", "Os suprimentos deste baú já foram recolhidos.")
		"vehicle":
			if GameManager.tutorial_step == 3 and GameManager.start_exploration():
				show_choices("Exploração inicial", "O rover ainda funciona. Escolha como investigar o local do impacto.", [
					{"label": "Avançar com cautela", "action": Callable(self, "_resolve_exploration").bind("careful")},
					{"label": "Seguir rapidamente", "action": Callable(self, "_resolve_exploration").bind("fast")}
				])
			elif GameManager.tutorial_step == 4:
				show_choices("Exploração inicial", "Escolha como investigar o local do impacto.", [
					{"label": "Avançar com cautela", "action": Callable(self, "_resolve_exploration").bind("careful")},
					{"label": "Seguir rapidamente", "action": Callable(self, "_resolve_exploration").bind("fast")}
				])
			else:
				_show_notice("Veículo de exploração", "O rover aguarda. Complete as construções do tutorial antes de partir.")
		"camp":
			if GameManager.return_to_camp():
				_show_notice("De volta ao acampamento", "As peças recuperadas permitem concluir a infraestrutura básica.")
			elif GameManager.tutorial_step == 7:
				_show_notice("Acampamento", "O tutorial do Dia 1 já foi concluído.")
			else:
				_show_notice("Acampamento", "Nenhuma ação necessária neste ponto.")

func _resolve_exploration(choice: String) -> void:
	if not GameManager.resolve_exploration(choice):
		_show_notice("Mochila sem espaço", "Abra o inventário e libere espaço para receber a recompensa.")
		return
	expedition_begin_requested.emit()
	_show_notice("Recompensa recuperada", "Você encontrou peças de reposição e metal. Retorne à área do acampamento.")

func open_inventory() -> void:
	_resize_overlay(1040.0, 620.0)
	overlay_title.text = "INVENTÁRIO  |  %d ESPAÇOS" % GameManager.INVENTORY_CAPACITY
	overlay_body.text = "Selecione um item para consultar seus dados e efeitos."
	overlay_body.show()
	inventory_section.show()
	choice_scroll.hide()
	map_radar.hide()
	_clear_choices()
	_update_inventory_view()
	_set_overlay_visible(true)

func _update_inventory_view() -> void:
	if inventory_buttons.is_empty():
		return
	if selected_inventory_slot < 0 or selected_inventory_slot >= GameManager.inventory.size():
		selected_inventory_slot = _find_first_occupied_inventory_slot()
	if selected_inventory_slot >= 0 and str(GameManager.inventory[selected_inventory_slot].get("id", "")) == "":
		selected_inventory_slot = _find_first_occupied_inventory_slot()
	for slot_index in range(inventory_buttons.size()):
		var slot: Dictionary = GameManager.inventory[slot_index]
		var item_id := str(slot.get("id", ""))
		var count := int(slot.get("count", 0))
		var item_label := inventory_item_labels[slot_index]
		item_label.text = GameManager.ITEM_NAMES.get(item_id, "Espaço vazio") if item_id != "" else "Vazio"
		inventory_count_labels[slot_index].text = "x%d" % count if item_id != "" else ""
		inventory_buttons[slot_index].disabled = item_id.is_empty()
		inventory_buttons[slot_index].tooltip_text = GameManager.ITEM_NAMES.get(item_id, "Espaço vazio") if item_id != "" else "Espaço vazio"
		inventory_icon_controls[slot_index].set("item_id", item_id if item_id != "" else "rations")
		_style_inventory_slot(inventory_buttons[slot_index], slot_index == selected_inventory_slot)
	_render_inventory_detail()

func _find_first_occupied_inventory_slot() -> int:
	for slot_index in range(GameManager.inventory.size()):
		if not str(GameManager.inventory[slot_index].get("id", "")).is_empty():
			return slot_index
	return -1

func _on_inventory_slot_pressed(slot_index: int) -> void:
	selected_inventory_slot = slot_index
	_update_inventory_view()

func _render_inventory_detail() -> void:
	if not is_instance_valid(inventory_detail_title):
		return
	if selected_inventory_slot < 0:
		inventory_detail_title.text = "NENHUM ITEM SELECIONADO"
		inventory_detail_description.text = "Recupere suprimentos para preencher a mochila."
		inventory_detail_effect.text = ""
		inventory_use_button.hide()
		return
	var slot: Dictionary = GameManager.inventory[selected_inventory_slot]
	var item_id := str(slot.get("id", ""))
	if item_id.is_empty():
		inventory_detail_title.text = "ESPAÇO VAZIO"
		inventory_detail_description.text = "Este compartimento está livre."
		inventory_detail_effect.text = ""
		inventory_use_button.hide()
		return
	inventory_detail_title.text = GameManager.ITEM_NAMES.get(item_id, item_id).to_upper()
	inventory_detail_description.text = ITEM_DESCRIPTIONS.get(item_id, "Recurso recuperado durante a missão.")
	inventory_detail_effect.text = ITEM_EFFECTS.get(item_id, "RECURSO")
	var consumable := item_id in ["rations", "water_bottle", "medkit"]
	inventory_use_button.visible = consumable
	if consumable:
		var target_stat := str({"rations": "hunger", "water_bottle": "water", "medkit": "health"}[item_id])
		inventory_use_button.disabled = int(slot.get("count", 0)) <= 0 or float(GameManager.stats.get(target_stat, 100.0)) >= 100.0

func _on_inventory_use_pressed() -> void:
	if selected_inventory_slot < 0:
		return
	var item_id := str(GameManager.inventory[selected_inventory_slot].get("id", ""))
	if GameManager.consume_item(item_id):
		_update_inventory_view()
	else:
		inventory_detail_effect.text = "SEM EFEITO  |  O atributo correspondente já está cheio."

func open_construction() -> void:
	var structures := {
		"habitat": {"title": "Habitat nível 1", "description": "Módulo pressurizado para proteger a tripulação."},
		"greenhouse": {"title": "Estufa nível 1", "description": "Produz alimentos e sustenta a base a longo prazo."},
		"miner": {"title": "Mineradora nível 1", "description": "Extrai materiais para futuras expansões."}
	}
	var choices: Array[Dictionary] = []
	for structure_id in ["habitat", "greenhouse", "miner"]:
		var resources: Array[Dictionary] = []
		for item_id in GameManager.BUILD_RECIPES[structure_id]:
			resources.append({"id": item_id, "amount": int(GameManager.BUILD_RECIPES[structure_id][item_id])})
		choices.append({
			"title": structures[structure_id]["title"],
			"description": structures[structure_id]["description"],
			"resources": resources,
			"action": Callable(self, "_build_structure").bind(structure_id),
			"enabled": GameManager.can_build(structure_id),
			"preview": structure_id
		})
	show_choices("Construção", "SELECIONE UM MÓDULO  |  Custos em estoque / necessários. A montagem respeita a etapa atual da missão.", choices)

func _build_structure(structure_id: String) -> void:
	if GameManager.build_structure(structure_id):
		if GameManager.tutorial_step == 7:
			_show_notice("Tutorial do Dia 1 concluído", "Habitat, estufa e mineradora estão operacionais. A astronauta está pronta para continuar a missão.")
		else:
			_show_notice("Construção concluída", "%s nível 1 construído." % str(structure_id).capitalize())
	else:
		_show_notice("Construção indisponível", "Confira a etapa do tutorial e os materiais necessários.")

func open_map() -> void:
	_resize_overlay(1040.0, 620.0)
	overlay_title.text = "CARTOGRAFIA DE MARTE"
	overlay_body.text = "SETOR CENTRAL  |  SOL %d  |  %s" % [GameManager.sol, GameManager.current_time]
	overlay_body.show()
	inventory_section.hide()
	choice_scroll.hide()
	_clear_choices()
	map_radar.call("set_map_state", GameManager.player_position, GameManager.tutorial_step)
	map_radar.show()
	_set_overlay_visible(true)

func open_journal() -> void:
	var choices: Array[Dictionary] = []
	for entry in SCIENCE_ENTRIES:
		choices.append({
			"title": "%s  /  %s%s" % [entry["category"], entry["title"], "  •  LIDO" if GameManager.diary_read.has(entry["id"]) else "  •  NOVO"],
			"description": entry["text"],
			"action": Callable(self, "_read_science_entry").bind(entry)
		})
	show_choices("Diário científico", "ARQUIVO DE MISSÃO  |  Registros científicos e referências oficiais.", choices)

func _read_science_entry(entry: Dictionary) -> void:
	if not GameManager.diary_read.has(entry["id"]):
		GameManager.diary_read.append(entry["id"])
		GameManager.save_game()
	_show_notice("%s | %s" % [entry["category"], entry["title"]], "%s\n\nFonte oficial: %s" % [entry["text"], entry["source"]])

func open_settings() -> void:
	show_choices("Configurações", "TRIPULAÇÃO %s  |  DIFICULDADE %s" % [GameManager.player_name, GameManager.difficulty.to_upper()], [
		{"title": "Salvar partida", "description": "Grava o estado atual da missão.", "action": Callable(self, "_save_now")},
		{"title": "Salvar e voltar ao menu", "description": "Grava a missão antes de retornar ao menu principal.", "action": Callable(self, "_save_and_exit")}
	])
	var fullscreen_toggle := CheckButton.new()
	fullscreen_toggle.text = "Tela cheia"
	fullscreen_toggle.set_pressed_no_signal(_is_fullscreen_mode())
	fullscreen_toggle.toggled.connect(_set_fullscreen_mode)
	fullscreen_toggle.add_theme_color_override("font_color", Color("#EAF4F6"))
	fullscreen_toggle.add_theme_color_override("font_hover_color", Color.WHITE)
	choice_container.add_child(fullscreen_toggle)
	choice_container.move_child(fullscreen_toggle, 0)
	choice_scroll.custom_minimum_size.y = 270
	_resize_overlay(980.0, 520.0)

func _is_fullscreen_mode() -> bool:
	var window_mode := DisplayServer.window_get_mode()
	return window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _set_fullscreen_mode(enabled: bool) -> void:
	var window_mode := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(window_mode)

func _save_now() -> void:
	_show_notice("Salvamento", "Partida salva." if GameManager.save_game() else "Não foi possível gravar o arquivo de salvamento.")

func _save_and_exit() -> void:
	if GameManager.save_game():
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	else:
		_show_notice("Salvamento falhou", "A partida não foi salva. Permaneça no jogo e tente novamente.")

func _on_quickbar_pressed(index: int) -> void:
	if is_modal_open() or index < 0 or index >= QUICKBAR_ITEMS.size():
		return
	var item_id: String = QUICKBAR_ITEMS[index]
	if item_id in ["rations", "water_bottle", "medkit"]:
		if GameManager.consume_item(item_id):
			_show_notice("Item usado", "%s aplicado." % GameManager.ITEM_NAMES[item_id])
		else:
			_show_notice("Item indisponível", "Você não possui %s ou o atributo correspondente já está cheio." % GameManager.ITEM_NAMES[item_id])
	else:
		_show_notice("Barra rápida", "%s: %d unidade(s)." % [GameManager.ITEM_NAMES[item_id], GameManager.get_item_count(item_id)])

func set_interaction_prompt(message: String) -> void:
	interaction_prompt_label.text = "[ E ]  " + message.trim_prefix("E | ") if message.begins_with("E | ") else message
	interaction_prompt.visible = not message.is_empty()

func is_modal_open() -> bool:
	return overlay != null and overlay.visible

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_ESCAPE:
			if is_modal_open():
				_close_overlay()
		KEY_I:
			open_inventory()
		KEY_B:
			open_construction()
		KEY_M:
			open_map()
		_:
			if not is_modal_open() and event.keycode >= KEY_1 and event.keycode <= KEY_6:
				_on_quickbar_pressed(event.keycode - KEY_1)

func update_hud() -> void:
	var stats = GameManager.stats
	name_label.text = GameManager.player_name if not GameManager.player_name.is_empty() else "Astra"
	portrait.set("gender", GameManager.gender)
	crew_label.text = "NASA / FEMININO" if GameManager.gender == "female" else "NASA / MASCULINO"
	health_bar.max_value = 100
	oxygen_bar.max_value = 100
	energy_bar.max_value = 100
	hunger_bar.max_value = 100
	water_bar.max_value = 100
	health_bar.value = GameManager.clamp_stat(float(stats.get("health", 100.0)))
	oxygen_bar.value = GameManager.clamp_stat(float(stats.get("oxygen", 100.0)))
	energy_bar.value = GameManager.clamp_stat(float(stats.get("energy", 100.0)))
	hunger_bar.value = GameManager.clamp_stat(float(stats.get("hunger", 100.0)))
	water_bar.value = GameManager.clamp_stat(float(stats.get("water", 100.0)))
	objective_label.text = GameManager.current_objective
	day_label.text = "DIA %d" % GameManager.day
	time_label.text = GameManager.current_time
	sol_label.text = "SOL %d" % GameManager.sol
	for index in range(QUICKBAR_ITEMS.size()):
		var item_id: String = QUICKBAR_ITEMS[index]
		var quickbar_button: Button = get_node("QuickBar/MarginContainer/HBoxContainer/Slot%d" % (index + 1))
		quickbar_item_labels[index].text = QUICKBAR_LABELS[index]
		quickbar_item_labels[index].tooltip_text = GameManager.ITEM_NAMES[item_id]
		quickbar_count_labels[index].text = "x%d" % GameManager.get_item_count(item_id)
		quickbar_button.disabled = GameManager.get_item_count(item_id) == 0
	_update_inventory_view()
