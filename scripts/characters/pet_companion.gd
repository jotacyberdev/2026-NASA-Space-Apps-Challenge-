extends Node2D

const ASSET_REGISTRY := preload("res://scripts/core/asset_registry.gd")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D
var pet_id := "pet_laika"
var facing_direction := "down"
var _using_sprite := false

func configure(follow_target: Node2D, selected_pet: String) -> void:
	player = follow_target
	pet_id = "pet_ham" if selected_pet == "monkey" else "pet_laika"
	if is_node_ready():
		_load_pet_frames()

func _ready() -> void:
	_load_pet_frames()

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var follow_offset := Vector2(-34.0, 20.0)
	var target := player.global_position + follow_offset
	global_position = global_position.lerp(target, minf(delta * 3.0, 1.0))
	if _using_sprite:
		var direction := target - global_position
		if direction.length() > 5.0:
			if absf(direction.x) > absf(direction.y):
				facing_direction = "right" if direction.x > 0.0 else "left"
			else:
				facing_direction = "down" if direction.y > 0.0 else "up"
			_play_animation("walk_" + facing_direction if direction.length() > 7.0 else "idle_" + facing_direction)

func _load_pet_frames() -> void:
	var sprite_frames: SpriteFrames = ASSET_REGISTRY.character_frames(pet_id)
	_using_sprite = sprite_frames != null
	animated_sprite.visible = _using_sprite
	if _using_sprite:
		animated_sprite.sprite_frames = sprite_frames
		animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_play_animation("idle_down")
	queue_redraw()

func _play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
			animated_sprite.play(animation_name)

func _draw() -> void:
	if _using_sprite:
		return
	var laika := pet_id == "pet_laika"
	var coat := Color("#D9C5A3") if laika else Color("#8C6D54")
	var dark_coat := Color("#795D4A") if laika else Color("#4E4139")
	draw_colored_polygon(PackedVector2Array([
		Vector2(-13, -2), Vector2(-9, -10), Vector2(4, -11), Vector2(12, -5),
		Vector2(12, 4), Vector2(5, 9), Vector2(-8, 8), Vector2(-14, 4)
	]), coat)
	draw_circle(Vector2(8, -8), 7.0, coat)
	if laika:
		draw_colored_polygon(PackedVector2Array([Vector2(4, -13), Vector2(3, -21), Vector2(8, -16)]), dark_coat)
		draw_colored_polygon(PackedVector2Array([Vector2(10, -13), Vector2(15, -20), Vector2(14, -12)]), dark_coat)
	else:
		draw_circle(Vector2(5, -12), 2.0, Color("#D6B87D"))
		draw_circle(Vector2(11, -12), 2.0, Color("#D6B87D"))
	draw_circle(Vector2(10, -9), 1.0, Color("#15232A"))
	draw_line(Vector2(-8, 5), Vector2(-10, 11), dark_coat, 2.4, true)
	draw_line(Vector2(1, 7), Vector2(0, 12), dark_coat, 2.4, true)
	draw_line(Vector2(8, 6), Vector2(9, 11), dark_coat, 2.4, true)
	draw_line(Vector2(-13, -1), Vector2(-19, -6 if laika else -9), coat, 2.5, true)
	draw_line(Vector2(-2, -8), Vector2(5, -6), Color("#E3A34C"), 2.0, true)
