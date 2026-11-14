extends Control

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
    $CenterContainer/VBoxContainer.add_theme_constant_override("separation", 10)
    _style_menu_button(new_game_button, true)
    _style_menu_button(load_game_button)
    _style_menu_button(settings_button)
    _style_menu_button(credits_button)
    _style_menu_button(exit_button)
    load_game_button.disabled = not GameManager.save_exists()
    if load_game_button.disabled:
        load_game_button.tooltip_text = "Nenhuma partida salva."
    _build_settings_dialog()

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
    dialog_style.bg_color = Color(0.045, 0.075, 0.105, 0.98)
    dialog_style.border_color = Color(0.25, 0.62, 0.76, 0.72)
    dialog_style.set_border_width_all(1)
    dialog_style.set_corner_radius_all(7)
    dialog_style.set_content_margin_all(18)
    settings_dialog.add_theme_stylebox_override("panel", dialog_style)
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

func _style_menu_button(button: Button, is_primary: bool = false) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#B9572B") if is_primary else Color(0.035, 0.085, 0.12, 0.88)
    normal.border_color = Color("#F3A24D") if is_primary else Color(0.22, 0.57, 0.69, 0.82)
    var hover := StyleBoxFlat.new()
    hover.bg_color = Color("#E37339") if is_primary else Color(0.07, 0.17, 0.22, 0.98)
    hover.border_color = Color("#FFD18A") if is_primary else Color("#5CD5E2")
    var pressed := StyleBoxFlat.new()
    pressed.bg_color = Color("#93401F") if is_primary else Color(0.035, 0.12, 0.16, 1.0)
    pressed.border_color = Color("#E78945") if is_primary else Color("#2B9FB5")
    var disabled := StyleBoxFlat.new()
    disabled.bg_color = Color(0.11, 0.14, 0.16, 0.78)
    disabled.border_color = Color(0.29, 0.36, 0.39, 0.58)
    for style in [normal, hover, pressed, disabled]:
        style.set_border_width_all(1)
        style.set_corner_radius_all(5)
        style.set_content_margin_all(8)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    button.add_theme_stylebox_override("disabled", disabled)
    button.add_theme_color_override("font_color", Color("#FFF3E3") if is_primary else Color("#E6F3F5"))
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color("#FFE0B6"))
    button.add_theme_color_override("font_disabled_color", Color(0.57, 0.65, 0.68, 0.75))
    button.add_theme_font_size_override("font_size", 15)

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
