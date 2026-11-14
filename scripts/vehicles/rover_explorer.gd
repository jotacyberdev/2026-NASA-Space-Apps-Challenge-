extends CharacterBody2D

const ASSET_REGISTRY := preload("res://scripts/core/asset_registry.gd")

@export var drive_speed := 230.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = $PromptLabel

var player_inside := false
var is_driving := false
var _using_sprite := false

func _ready() -> void:
	var frames: SpriteFrames = ASSET_REGISTRY.rover_frames()
	_using_sprite = frames != null
	sprite.visible = _using_sprite
	if _using_sprite:
		sprite.sprite_frames = frames
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_play_rover_animation("idle")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	prompt_label.hide()
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if not is_driving:
		velocity = Vector2.ZERO
		return
	var drive_direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		drive_direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		drive_direction.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		drive_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		drive_direction.x += 1.0
	velocity = drive_direction.normalized() * drive_speed if drive_direction != Vector2.ZERO else Vector2.ZERO
	move_and_slide()
	if _using_sprite:
		var animation_name := "idle"
		if drive_direction != Vector2.ZERO:
			if absf(drive_direction.x) > absf(drive_direction.y):
				animation_name = "drive_right" if drive_direction.x > 0.0 else "drive_left"
			else:
				animation_name = "drive_down" if drive_direction.y > 0.0 else "drive_up"
		_play_rover_animation(animation_name)

func toggle_drive(player: CharacterBody2D) -> void:
	if is_driving:
		is_driving = false
		player.global_position = global_position + Vector2(42.0, 12.0)
		player.show()
		player.set("controls_enabled", true)
		prompt_label.hide()
		return
	if not player_inside:
		return
	is_driving = true
	player.global_position = global_position
	player.hide()
	player.set("controls_enabled", false)
	prompt_label.text = "[E] Sair do Rover  |  WASD para dirigir"
	prompt_label.show()

func set_prompt_active(active: bool, is_tutorial_interaction: bool = false) -> void:
	if is_driving:
		prompt_label.text = "[E] Sair do Rover  |  WASD para dirigir"
		prompt_label.show()
		return
	if not player_inside or not active or is_tutorial_interaction:
		prompt_label.hide()
		return
	prompt_label.text = "[E] Entrar no Rover"
	prompt_label.show()

func _play_rover_animation(animation_name: String) -> void:
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name or not sprite.is_playing():
			sprite.play(animation_name)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Astronaut":
		return
	player_inside = true
	if not is_driving:
		prompt_label.text = "[E] Entrar no Rover"
		prompt_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name != "Astronaut" or is_driving:
		return
	player_inside = false
	prompt_label.hide()

func _draw() -> void:
	if _using_sprite:
		return
	draw_colored_polygon(PackedVector2Array([
		Vector2(-72, -24), Vector2(-58, -42), Vector2(45, -42), Vector2(70, -21),
		Vector2(76, 17), Vector2(54, 29), Vector2(-61, 29), Vector2(-77, 12)
	]), Color("#9BA9AB"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34, -38), Vector2(-21, -61), Vector2(20, -61), Vector2(34, -38)
	]), Color("#D0D9D7"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-22, -40), Vector2(-14, -55), Vector2(14, -55), Vector2(23, -40)
	]), Color("#174153"))
	draw_line(Vector2(-62, 1), Vector2(62, 1), Color("#DE914A"), 7.0, true)
	for wheel_x in [-48.0, 48.0]:
		draw_circle(Vector2(wheel_x, 27), 15.0, Color("#17242B"))
		draw_arc(Vector2(wheel_x, 27), 10.0, 0.0, TAU, 24, Color("#819395"), 2.0, true)
	draw_line(Vector2(50, -42), Vector2(62, -69), Color("#C8D1CF"), 2.0, true)
	draw_circle(Vector2(62, -69), 3.0, Color("#E3A34C"))
