extends CharacterBody2D

const ROVER_SPRITE_PATH := "res://assets/sprites/vehicles/rover/"
const SPEED := 240.0

var facing_direction := "right"
var is_driving := false
var prompt_active := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_setup_rover_visuals()


func enter_rover() -> void:
	is_driving = true


func exit_rover() -> void:
	is_driving = false


func set_prompt_active(active: bool, _can_interact: bool = false) -> void:
	prompt_active = active


func _setup_rover_visuals() -> void:
	var idle_path := ROVER_SPRITE_PATH + "Parado.png"
	if ResourceLoader.exists(idle_path):
		var tex: Texture2D = load(idle_path)
		if tex != null:
			var sprite := get_node_or_null("Sprite2D") as Sprite2D
			if sprite == null:
				sprite = Sprite2D.new()
				sprite.name = "Sprite2D"
				add_child(sprite)
			sprite.texture = tex
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var w := tex.get_width()
			var h := tex.get_height()
			if w > int(h * 1.5) and h > 0:
				sprite.region_enabled = true
				sprite.region_rect = Rect2(0, 0, h, h)


func _physics_process(_delta: float) -> void:
	if not is_driving:
		return
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_dir * SPEED
	move_and_slide()
