extends CharacterBody2D
@export var move_speed: float = 170.0
@export var run_speed: float = 300.0
@export var controls_enabled := true
@onready var camera: Camera2D = $Camera2D
@onready var body_visual: Polygon2D = $BodyVisual
@onready var helmet: Polygon2D = $Helmet
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var facing_direction := "down"
var _playing_action := false
var is_running := false
const CHARACTER_FEMALE_PATH := "res://assets/sprites/characters/sofia/"
const CHARACTER_MALE_PATH := "res://assets/sprites/characters/male/"
func _ready() -> void:
	camera.make_current()
	camera.enabled = true
	var gender := GameManager.gender
	var sprite_data := _load_character_sprites(gender)
	var sprite_frames := SpriteFrames.new()

	var idle_animations := {"down": "frente_region", "up": "tras_region", "left": "esquerda_region", "right": "direita_region"}
	for dir_name in idle_animations:
		var key: String = idle_animations[dir_name]
		if sprite_data.has(key):
			var region := sprite_data[key] as Rect2
			var atlas := AtlasTexture.new()
			atlas.atlas = sprite_data.get(key + "_tex", null)
			atlas.region = region
			atlas.filter_clip = true
			var anim_name: String = "idle_" + dir_name

			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 8.0)
			sprite_frames.set_animation_loop(anim_name, true)
			sprite_frames.add_frame(anim_name, atlas)

	if sprite_data.has("andando_frente_frames"):
		var walk_frames := sprite_data["andando_frente_frames"] as Array
		for frame in walk_frames:
			var anim_name := "walk_down"
			if not sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 8.0)
			sprite_frames.set_animation_loop(anim_name, true)
			sprite_frames.add_frame(anim_name, frame)

	# Create walk_up animation using Tras.png frames sliced horizontally
	var walk_up_textures := []
	if sprite_data.has("andando_tras_frames"):
		var walk_up_frames := sprite_data["andando_tras_frames"] as Array
		for frame in walk_up_frames:
			walk_up_textures.append(frame)
	else:
		# Try to use the same walk texture but slice vertically for up direction
		var walk_tex_path := CHARACTER_FEMALE_PATH + "Andando_Frente.png"
		if ResourceLoader.exists(walk_tex_path):
			var walk_tex: Texture2D = load(walk_tex_path)
			if walk_tex != null and walk_tex.get_height() > 0:
				var h := walk_tex.get_height()
				var count := maxi(1, int(round(float(walk_tex.get_width()) / float(h))))
				for i in range(count):
					var atlas := AtlasTexture.new()
					atlas.atlas = walk_tex
					atlas.region = Rect2(i * h, 0, h, h)
					atlas.filter_clip = true
					walk_up_textures.append(atlas)

	if walk_up_textures.size() > 0:
		var anim_name := "walk_up"
		if not sprite_frames.has_animation(anim_name):
			sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite_frames.set_animation_loop(anim_name, true)
		for frame in walk_up_textures:
			sprite_frames.add_frame(anim_name, frame)

	# Create walk_left animation using Esquerda.png frames sliced vertically
	var walk_left_textures := []
	var esquerda_tex_path := CHARACTER_FEMALE_PATH + "Esquerda.png"
	if ResourceLoader.exists(esquerda_tex_path):
		var esquerda_tex: Texture2D = load(esquerda_tex_path)
		if esquerda_tex != null and esquerda_tex.get_width() > 0:
			var w := esquerda_tex.get_width()
			var h := maxi(1, int(round(float(esquerda_tex.get_height()) / 4.0)))  # assume 4 frames vertically
			for i in range(4):
				if i * h < esquerda_tex.get_height():
					var atlas := AtlasTexture.new()
					atlas.atlas = esquerda_tex
					atlas.region = Rect2(0, i * h, w, h)
					atlas.filter_clip = true
					walk_left_textures.append(atlas)

	if walk_left_textures.size() > 0:
		var anim_name := "walk_left"
		if not sprite_frames.has_animation(anim_name):
			sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite_frames.set_animation_loop(anim_name, true)
		for frame in walk_left_textures:
			sprite_frames.add_frame(anim_name, frame)

	# Create walk_right animation using Direita.png frames sliced vertically
	var walk_right_textures := []
	var direita_tex_path := CHARACTER_FEMALE_PATH + "Direita.png"
	if ResourceLoader.exists(direita_tex_path):
		var direita_tex: Texture2D = load(direita_tex_path)
		if direita_tex != null and direita_tex.get_width() > 0:
			var w := direita_tex.get_width()
			var h := maxi(1, int(round(float(direita_tex.get_height()) / 4.0)))
			for i in range(4):
				if i * h < direita_tex.get_height():
					var atlas := AtlasTexture.new()
					atlas.atlas = direita_tex
					atlas.region = Rect2(0, i * h, w, h)
					atlas.filter_clip = true
					walk_right_textures.append(atlas)

	if walk_right_textures.size() > 0:
		var anim_name := "walk_right"
		if not sprite_frames.has_animation(anim_name):
			sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8.0)
		sprite_frames.set_animation_loop(anim_name, true)
		for frame in walk_right_textures:
			sprite_frames.add_frame(anim_name, frame)

	if sprite_frames.get_frame_count("idle_down") > 0:
			animated_sprite.sprite_frames = sprite_frames
			animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			animated_sprite.visible = true
			_set_procedural_visuals_visible(false)
			animated_sprite.animation_finished.connect(_on_sprite_animation_finished)
			_play_animation("idle_down")
	else:
		animated_sprite.hide()
		_set_procedural_visuals_visible(true)


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
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("idle_down"):
			var tex := animated_sprite.sprite_frames.get_frame_texture("idle_down", 0)
			if tex != null and tex.get_height() > 0:
				var s := 64.0 / float(tex.get_height())
				animated_sprite.scale = Vector2(s, s)

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return

	# Read input - both mapped actions and keyboard fallback
	var move_dir := Vector2.ZERO

	# Horizontal movement
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A):
		move_dir.x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D):
		move_dir.x += 1.0

	# Vertical movement
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W):
		move_dir.y -= 1.0
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S):
		move_dir.y += 1.0

	# Normalize if diagonal
	if move_dir.length_squared() > 0:
		move_dir = move_dir.normalized()

	# Check for running (Shift) - multiply speed by 1.6
	is_running = Input.is_action_pressed("ui_shift") or Input.is_key_pressed(KEY_SHIFT)
	var final_speed := move_speed * 1.6 if is_running else move_speed


	# Apply movement
	velocity = move_dir * final_speed
	move_and_slide()

	# Update animation based on velocity
	if velocity.length() > 5.0:
		# Moving - update facing and play walk animation
		_update_facing(velocity)
		var current_anim := "walk_" + facing_direction
		if animated_sprite.sprite_frames.has_animation(current_anim):
			_play_animation(current_anim)
	else:
		# Idle - play idle animation
		_play_animation("idle_" + facing_direction)

func _load_character_sprites(selected_gender: String) -> Dictionary:
	var base_path := CHARACTER_FEMALE_PATH if selected_gender == "female" else CHARACTER_MALE_PATH
	var result := {}
	var idle_files := {
		"frente_region": "Frente.png",
		"tras_region": "Tras.png",
		"esquerda_region": "Esquerda.png",
		"direita_region": "Direita.png"
	}
	for key in idle_files:
		var path: String = base_path + idle_files[key]
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path)
			if tex != null:
				var frame_size := mini(tex.get_width(), tex.get_height())
				result[key] = Rect2(0, 0, frame_size, frame_size)
				result[key + "_tex"] = tex

	var walk_path := base_path + "Andando_Frente.png"
	if ResourceLoader.exists(walk_path):
		var walk_tex: Texture2D = load(walk_path)
		if walk_tex != null and walk_tex.get_height() > 0:
			var h := walk_tex.get_height()
			var count := maxi(1, int(round(float(walk_tex.get_width()) / float(h))))
			var frames: Array[Texture2D] = []
			for i in range(count):
				var atlas := AtlasTexture.new()
				atlas.atlas = walk_tex
				atlas.region = Rect2(i * h, 0, h, h)
				atlas.filter_clip = true
				frames.append(atlas)
			result["andando_frente_frames"] = frames

	return result
