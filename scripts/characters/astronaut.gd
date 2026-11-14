extends CharacterBody2D

const ASSET_REGISTRY := preload("res://scripts/core/asset_registry.gd")

@export var move_speed: float = 170.0
@export var controls_enabled := true

@onready var camera: Camera2D = $Camera2D
@onready var body_visual: Polygon2D = $BodyVisual
@onready var helmet: Polygon2D = $Helmet
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction := "down"
var _playing_action := false

func _ready() -> void:
    camera.make_current()
    camera.enabled = true
    var character_id := "astronaut_female" if GameManager.gender == "female" else "astronaut_male"
    var sprite_frames: SpriteFrames = ASSET_REGISTRY.character_frames(character_id)
    if sprite_frames != null:
        animated_sprite.sprite_frames = sprite_frames
        animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        animated_sprite.visible = true
        _set_procedural_visuals_visible(false)
        animated_sprite.animation_finished.connect(_on_sprite_animation_finished)
        _play_animation("idle_down")
    else:
        animated_sprite.hide()
        _set_procedural_visuals_visible(true)

func _physics_process(_delta: float) -> void:
    if not controls_enabled:
        velocity = Vector2.ZERO
        return
    var direction := Vector2.ZERO

    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        direction.y -= 1
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        direction.y += 1
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        direction.x -= 1
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        direction.x += 1

    if direction != Vector2.ZERO:
        direction = direction.normalized()
        velocity = direction * move_speed
        _update_facing(direction)
    else:
        velocity = Vector2.ZERO

    move_and_slide()

    if velocity.length() > 0.0:
        body_visual.color = Color(0.86, 0.75, 0.92, 1.0)
        helmet.position = Vector2(0.0, -8.0)
        if not _playing_action and animated_sprite.visible:
            _play_animation("walk_" + facing_direction)
    else:
        body_visual.color = Color(0.82, 0.73, 0.90, 1.0)
        helmet.position = Vector2(0.0, -8.0)
        if not _playing_action and animated_sprite.visible:
            _play_animation("idle_" + facing_direction)

func play_action_animation(action_name: String) -> void:
    if not animated_sprite.visible:
        return
    if not animated_sprite.sprite_frames.has_animation(action_name):
        return
    _playing_action = true
    animated_sprite.sprite_frames.set_animation_loop(action_name, false)
    _play_animation(action_name)

func _update_facing(direction: Vector2) -> void:
    if absf(direction.x) > absf(direction.y):
        facing_direction = "right" if direction.x > 0.0 else "left"
    else:
        facing_direction = "down" if direction.y > 0.0 else "up"

func _play_animation(animation_name: String) -> void:
    if animated_sprite.sprite_frames == null or not animated_sprite.sprite_frames.has_animation(animation_name):
        return
    if animated_sprite.animation != animation_name or not animated_sprite.is_playing():
        animated_sprite.play(animation_name)

func _on_sprite_animation_finished() -> void:
    if not _playing_action:
        return
    _playing_action = false
    animated_sprite.sprite_frames.set_animation_loop(animated_sprite.animation, true)
    _play_animation("idle_" + facing_direction)

func _set_procedural_visuals_visible(is_visible: bool) -> void:
    for node_path in ["ContactShadow", "Backpack", "BodyVisual", "ChestPlate", "ChestStripe", "Helmet"]:
        var visual := get_node_or_null(node_path) as CanvasItem
        if visual != null:
            visual.visible = is_visible
