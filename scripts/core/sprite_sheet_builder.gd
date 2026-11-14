class_name SpriteSheetBuilder
extends RefCounted

static func build_sprite_frames(
	texture: Texture2D,
	columns: int,
	rows: int,
	animation_cells: Dictionary,
	frames_per_second: float = 8.0,
	loop_animations: bool = true,
	skip_empty_cells: bool = true,
	alpha_threshold: float = 0.01
) -> SpriteFrames:
	if texture == null or columns <= 0 or rows <= 0:
		push_error("SpriteSheetBuilder: textura, colunas e linhas precisam ser válidas.")
		return null

	var cell_width := floori(float(texture.get_width()) / float(columns))
	var cell_height := floori(float(texture.get_height()) / float(rows))
	if cell_width <= 0 or cell_height <= 0:
		push_error("SpriteSheetBuilder: a folha é menor que a grade solicitada.")
		return null

	var image := texture.get_image() if skip_empty_cells else null
	var sprite_frames := SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")

	for animation_name in animation_cells:
		var frame_indices: Array = animation_cells[animation_name]
		if frame_indices.is_empty():
			continue
		sprite_frames.add_animation(str(animation_name))
		sprite_frames.set_animation_speed(str(animation_name), frames_per_second)
		sprite_frames.set_animation_loop(str(animation_name), loop_animations)
		for cell_index_variant in frame_indices:
			var cell_index := int(cell_index_variant)
			if cell_index < 0 or cell_index >= columns * rows:
				push_warning("SpriteSheetBuilder: índice de célula fora da grade: %d." % cell_index)
				continue
			var column := cell_index % columns
			var row := floori(float(cell_index) / float(columns))
			var region := Rect2i(column * cell_width, row * cell_height, cell_width, cell_height)
			if skip_empty_cells and _cell_is_empty(image, region, alpha_threshold):
				continue
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(region)
			atlas.filter_clip = true
			sprite_frames.add_frame(str(animation_name), atlas)
		if sprite_frames.get_frame_count(str(animation_name)) == 0:
			sprite_frames.remove_animation(str(animation_name))

	if sprite_frames.get_animation_names().is_empty():
		push_error("SpriteSheetBuilder: a folha não contém frames utilizáveis.")
		return null
	return sprite_frames

static func build_animated_sprite(
	texture: Texture2D,
	columns: int,
	rows: int,
	animation_cells: Dictionary,
	frames_per_second: float = 8.0,
	loop_animations: bool = true,
	skip_empty_cells: bool = true
) -> AnimatedSprite2D:
	var sprite_frames := build_sprite_frames(
		texture,
		columns,
		rows,
		animation_cells,
		frames_per_second,
		loop_animations,
		skip_empty_cells
	)
	if sprite_frames == null:
		return null
	var animated_sprite := AnimatedSprite2D.new()
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return animated_sprite

static func _cell_is_empty(image: Image, region: Rect2i, alpha_threshold: float) -> bool:
	if image == null or image.is_empty():
		return false
	for y in range(region.position.y, region.position.y + region.size.y):
		for x in range(region.position.x, region.position.x + region.size.x):
			if image.get_pixel(x, y).a > alpha_threshold:
				return false
	return true
