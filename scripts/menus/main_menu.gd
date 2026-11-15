extends Control

const WARM_THEME := preload("res://scripts/ui/warm_sci_fi_theme.gd")
const MENU_ICON_SCRIPT := preload("res://scripts/ui/menu_action_icon.gd")

@onready var new_game_button: Button = $CenterContainer/VBoxContainer/NewGameButton
@onready var load_game_button: Button = $CenterContainer/VBoxContainer/LoadGameButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var credits_button: Button = $CenterContainer/VBoxContainer/CreditsButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton
@onready var new_game_dialog: ConfirmationDialog = $NewGameDialog
@onready var exit_dialog: ConfirmationDialog = $ExitDialog
@onready var message_dialog: AcceptDialog = $MessageDialog

var settings_dialog: AcceptDialog
var fullscreen_toggle: CheckButton
func _ready() -> void:
	for child in get_children():
		if child is ColorRect and child.name != "Background":
			child.visible = false
		elif child is Panel and child.name != "MenuPanel":
			child.visible = false
	$CenterContainer/VBoxContainer.add_theme_constant_override("separation", 16)
	_style_menu_button(new_game_button, "start", true)
	_style_menu_button(load_game_button, "load")
	_style_menu_button(settings_button, "settings")
	_style_menu_button(credits_button, "credits")
	_style_menu_button(exit_button, "exit")
	load_game_button.disabled = not GameManager.save_exists()
	if load_game_button.disabled:
		load_game_button.tooltip_text = "Nenhuma partida salva."
	_build_settings_dialog()
	_try_load_background()

func _try_load_background() -> void:
	var bg_tex := WARM_THEME.load_texture("res://assets/ui/bg_main_menu.png")
	var bg_node := $Background as ColorRect
	if bg_tex != null:
		bg_node.texture = bg_tex
		bg_node.material = null
		bg_node.custom_minimum_size = Vector2.ZERO
	else:
		bg_node.color = Color(0.13, 0.1, 0.12, 1)

func _on_new_game_pressed() -> void:
	if GameManager.save_exists():
		new_game_dialog.popup_centered()
	else:
		_start_new_game()

func _on_load_game_pressed() -> void:
	if GameManager.load_game():
		get_tree().change_scene_to_file("res://scenes/world/mars_base.tscn")
		return
	message_dialog.dialog_text = "Não foi possível carregar a partida salva."
	message_dialog.popup_centered()

func _on_settings_pressed() -> void:
	fullscreen_toggle.set_pressed_no_signal(_is_fullscreen_mode())
	settings_dialog.popup_centered()

func _build_settings_dialog() -> void:
	settings_dialog = AcceptDialog.new()
	settings_dialog.title = "Configurações"
	settings_dialog.size = Vector2i(420, 220)
	var dialog_style := StyleBoxFlat.new()
	dialog_style.bg_color = Color(0.11, 0.06, 0.04, 0.96)
	dialog_style.border_color = WARM_THEME.COPPER
	dialog_style.set_border_width_all(1)
	dialog_style.set_corner_radius_all(7)
	dialog_style.set_content_margin_all(18)
	settings_dialog.add_theme_stylebox_override("panel", dialog_style)
	# Remove OK button: close only with ESC or X
	var ok_button: Button = settings_dialog.get_ok_button()
	if ok_button != null:
		ok_button.hide()
	add_child(settings_dialog)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	settings_dialog.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)
	var volume_label := Label.new()
	volume_label.text = "Volume principal"
	volume_label.add_theme_color_override("font_color", Color("#E8F0F3"))
	content.add_child(volume_label)
	var volume_slider := HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		volume_slider.value = AudioServer.get_bus_volume_linear(master_bus)
		volume_slider.value_changed.connect(_on_master_volume_changed)
	content.add_child(volume_slider)
	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "Tela cheia"
	fullscreen_toggle.button_pressed = _is_fullscreen_mode()
	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	content.add_child(fullscreen_toggle)

func _style_menu_button(button: Button, action_id: String, is_primary: bool = false) -> void:
		WARM_THEME.apply_button(button, is_primary)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = "        " + button.text
		var icon := Control.new()
		icon.set_script(MENU_ICON_SCRIPT)
		icon.set("action_id", action_id)
		icon.custom_minimum_size = Vector2(36, 36)
		icon.set_anchors_preset(Control.PRESET_CENTER_LEFT)
		icon.offset_left = 8
		icon.offset_top = -17
		icon.offset_right = 48
		icon.offset_bottom = 17
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(icon)
		var stylebox := button.get_theme_stylebox("normal")
		if stylebox != null:
			stylebox.content_margin_left = 56
			button.add_theme_stylebox_override("normal", stylebox)
		var hover_style := button.get_theme_stylebox("hover")
		if hover_style != null:
			hover_style.content_margin_left = 56
			button.add_theme_stylebox_override("hover", hover_style)
		var pressed_style := button.get_theme_stylebox("pressed")
		if pressed_style != null:
			pressed_style.content_margin_left = 56
			button.add_theme_stylebox_override("pressed", pressed_style)
		var focus_style := button.get_theme_stylebox("focus")
		if focus_style != null:
			focus_style.content_margin_left = 56
			button.add_theme_stylebox_override("focus", focus_style)

func _is_fullscreen_mode() -> bool:
	var window_mode := DisplayServer.window_get_mode()
	return window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or window_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

func _on_master_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_linear(master_bus, value)

func _on_fullscreen_toggled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _on_credits_pressed() -> void:
	message_dialog.dialog_text = "Mars: Last Survivor\n\nJoão Pedro de Castro Abreu\nKainã Matheus da Rocha Souza\nEduardo Henrique de Souza Santos\nLuiz Guilherme Vilhena Pereira\nRaphael Leon de Paula Rodrigues"
	message_dialog.popup_centered()

func _on_exit_pressed() -> void:
	exit_dialog.popup_centered()

func _on_confirm_new_game() -> void:
	_start_new_game()

func _on_confirm_exit() -> void:
	get_tree().quit()

func _start_new_game() -> void:
	GameManager.reset_defaults()
	get_tree().change_scene_to_file("res://scenes/menus/character_creation.tscn")
