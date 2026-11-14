extends Control

@onready var name_edit: LineEdit = $CenterContainer/Panel/Margin/VBox/NameContainer/NameEdit
@onready var male_button: Button = $CenterContainer/Panel/Margin/VBox/GenderContainer/MaleButton
@onready var female_button: Button = $CenterContainer/Panel/Margin/VBox/GenderContainer/FemaleButton
@onready var dog_button: Button = $CenterContainer/Panel/Margin/VBox/PetContainer/DogButton
@onready var monkey_button: Button = $CenterContainer/Panel/Margin/VBox/PetContainer/MonkeyButton
@onready var easy_button: Button = $CenterContainer/Panel/Margin/VBox/DifficultyContainer/EasyButton
@onready var normal_button: Button = $CenterContainer/Panel/Margin/VBox/DifficultyContainer/NormalButton
@onready var hard_button: Button = $CenterContainer/Panel/Margin/VBox/DifficultyContainer/HardButton
@onready var continue_button: Button = $CenterContainer/Panel/Margin/VBox/Buttons/ContinueButton
@onready var back_button: Button = $CenterContainer/Panel/Margin/VBox/Buttons/BackButton
@onready var error_label: Label = $CenterContainer/Panel/Margin/VBox/ErrorLabel

var selected_gender := "female"
var selected_pet := "dog"
var selected_difficulty := "normal"

func _ready() -> void:
    _select_gender(selected_gender)
    _select_pet(selected_pet)
    _select_difficulty(selected_difficulty)
    name_edit.text = GameManager.player_name if GameManager.player_name != "Astra" else ""
    error_label.text = ""

func _select_gender(value: String) -> void:
    selected_gender = value
    male_button.button_pressed = value == "male"
    female_button.button_pressed = value == "female"

func _select_pet(value: String) -> void:
    selected_pet = value
    dog_button.button_pressed = value == "dog"
    monkey_button.button_pressed = value == "monkey"

func _select_difficulty(value: String) -> void:
    selected_difficulty = value
    easy_button.button_pressed = value == "easy"
    normal_button.button_pressed = value == "normal"
    hard_button.button_pressed = value == "hard"

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
