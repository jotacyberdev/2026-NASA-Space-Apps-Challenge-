class_name AssetRegistry
extends RefCounted

const SPRITE_SHEET_BUILDER := preload("res://scripts/core/sprite_sheet_builder.gd")

const CHARACTER_SPRITES := {
	"astronaut_female": "res://assets/sprites/characters/astronaut_female_sheet.png",
	"astronaut_male": "res://assets/sprites/characters/astronaut_male_sheet.png",
	"pet_laika": "res://assets/sprites/characters/pet_laika_sheet.png",
	"pet_ham": "res://assets/sprites/characters/pet_ham_sheet.png"
}
const VEHICLE_SPRITES := {
	"rover_explorer": "res://assets/sprites/vehicles/rover_explorer_sheet.png"
}
const BUILDING_SPRITES := {
	"habitat": "res://assets/sprites/buildings/habitat_lvl1.png",
	"workshop": "res://assets/sprites/buildings/workshop_lvl1.png",
	"warehouse": "res://assets/sprites/buildings/warehouse_lvl1.png",
	"greenhouse": "res://assets/sprites/buildings/greenhouse_lvl1.png",
	"solar_panel": "res://assets/sprites/buildings/solar_panel_lvl1.png",
	"comm_antenna": "res://assets/sprites/buildings/comm_antenna_lvl1.png",
	"laboratory": "res://assets/sprites/buildings/laboratory_lvl1.png",
	"pet_shelter": "res://assets/sprites/buildings/pet_shelter_lvl1.png",
	"crashed_ship": "res://assets/sprites/buildings/crashed_ship.png"
}
const UI_SPRITES := {
	"logo_mars": "res://assets/ui/logo_mars.png",
	"menu_bg": "res://assets/ui/menu_bg.png",
	"portrait_female": "res://assets/ui/portrait_female.png",
	"portrait_male": "res://assets/ui/portrait_male.png",
	"portrait_laika": "res://assets/ui/portrait_laika.png",
	"portrait_ham": "res://assets/ui/portrait_ham.png",
	"intro_1": "res://assets/ui/intro_1.png",
	"intro_2": "res://assets/ui/intro_2.png",
	"intro_3": "res://assets/ui/intro_3.png",
	"intro_4": "res://assets/ui/intro_4.png"
}

const CHARACTER_ANIMATIONS := {
	"idle_down": [0],
	"idle_up": [0],
	"idle_left": [0],
	"idle_right": [0],
	"walk_down": [8, 9, 10, 11],
	"walk_up": [16, 17, 18, 19],
	"walk_right": [24, 25, 26, 27],
	"walk_left": [32, 33, 34, 35],
	"interact": [40, 41, 42, 43],
	"build": [48, 49, 50, 51],
	"mine": [56, 57, 58, 59],
	"run": [64, 65, 66, 67]
}
const PET_ANIMATIONS := {
	"idle_down": [0],
	"idle_up": [0],
	"idle_left": [0],
	"idle_right": [0],
	"walk_down": [8, 9, 10, 11],
	"walk_up": [16, 17, 18, 19],
	"walk_right": [24, 25, 26, 27],
	"walk_left": [32, 33, 34, 35]
}
const ROVER_ANIMATIONS := {
	"idle": [0],
	"drive_right": [7, 8, 9, 10],
	"drive_left": [14, 15, 16, 17],
	"drive_up": [21, 22, 23, 24],
	"drive_down": [28, 29, 30, 31]
}

static func character_texture(character_id: String) -> Texture2D:
	return _load_texture(CHARACTER_SPRITES.get(character_id, ""))

static func character_frames(character_id: String) -> SpriteFrames:
	var texture := character_texture(character_id)
	if texture == null:
		return null
	var is_pet := character_id.begins_with("pet_")
	var layout: Dictionary = PET_ANIMATIONS if is_pet else CHARACTER_ANIMATIONS
	var rows := 5 if is_pet else 9
	var columns := 8
	return SPRITE_SHEET_BUILDER.build_sprite_frames(texture, columns, rows, layout, 8.0, true, true)

static func rover_frames() -> SpriteFrames:
	var texture := _load_texture(VEHICLE_SPRITES["rover_explorer"])
	if texture == null:
		return null
	return SPRITE_SHEET_BUILDER.build_sprite_frames(texture, 7, 5, ROVER_ANIMATIONS, 8.0, true, true)

static func building_texture(structure_id: String) -> Texture2D:
	return _load_texture(BUILDING_SPRITES.get(structure_id, ""))

static func ui_texture(asset_id: String) -> Texture2D:
	return _load_texture(UI_SPRITES.get(asset_id, ""))

static func asset_path(asset_id: String) -> String:
	if CHARACTER_SPRITES.has(asset_id):
		return CHARACTER_SPRITES[asset_id]
	if VEHICLE_SPRITES.has(asset_id):
		return VEHICLE_SPRITES[asset_id]
	if BUILDING_SPRITES.has(asset_id):
		return BUILDING_SPRITES[asset_id]
	return UI_SPRITES.get(asset_id, "")

static func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D
