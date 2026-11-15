extends Node2D

const STRUCTURE_VIEW_SCRIPT := preload("res://scripts/world/base_structure_view.gd")

const SURVIVAL_TICK_SECONDS := 1.0
const AUTOSAVE_INTERVAL_SECONDS := 15.0
const INTERACTION_RADIUS := 135.0
const CAMP_POSITION := Vector2(980, 650)
const EXPEDITION_POSITION := Vector2(1510, 950)
const HABITAT_POSITION := Vector2(520, 540)

# Resource node positions (world coordinates)
const RESOURCE_NODES := [
	{"id": "metal_scrap_1", "item": "metal", "amount": 5, "position": Vector2(400, 400)},
	{"id": "metal_scrap_2", "item": "metal", "amount": 5, "position": Vector2(1600, 450)},
	{"id": "polymer_crystal_1", "item": "polymer", "amount": 3, "position": Vector2(800, 300)},
	{"id": "polymer_crystal_2", "item": "polymer", "amount": 3, "position": Vector2(1400, 700)},
	{"id": "mineral_deposit_1", "item": "metal", "amount": 8, "position": Vector2(300, 900)},
	{"id": "mineral_deposit_2", "item": "metal", "amount": 8, "position": Vector2(1700, 600)},
]

var collected_resources: Array = []

@onready var survival_timer: Timer = $SurvivalTimer
var autosave_elapsed := 0.0
var fainted := false
var selected_structure_preview := ""
var structure_views: Dictionary = {}

@onready var player: CharacterBody2D = $Astronaut
@onready var hud = $HUD
@onready var rover: CharacterBody2D = $RoverExplorer
@onready var pet_companion: Node2D = $PetCompanion

func _ready() -> void:
	player.global_position = GameManager.player_position
	pet_companion.configure(player, GameManager.pet)
	_create_dust_particles()
	_setup_structure_views()
	hud.expedition_begin_requested.connect(_move_to_expedition)
	hud.modal_visibility_changed.connect(_on_modal_visibility_changed)
	hud.construction_preview_changed.connect(_set_construction_preview)
	GameManager.state_changed.connect(_refresh_structures)
	survival_timer.wait_time = SURVIVAL_TICK_SECONDS
	survival_timer.timeout.connect(_on_survival_timer_timeout)
	survival_timer.start()
	_refresh_structures()
	_update_interaction_prompt()

	# Expand camera limits for larger explorable area
	var camera = player.get_node_or_null("Camera2D")
	if camera != null:
		camera.limit_left = 100
		camera.limit_right = 1900
		camera.limit_top = 100
		camera.limit_bottom = 1100
		camera.offset = Vector2(0, 0)

func _create_dust_particles() -> void:
	var particles := GPUParticles2D.new()
	particles.name = "WindblownDust"
	particles.position = Vector2(1000, 600)
	particles.amount = 54
	particles.lifetime = 16.0
	particles.preprocess = 6.0
	particles.z_index = 1
	particles.visibility_rect = Rect2(-1450, -850, 2900, 1700)
	var particle_material := ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_material.emission_box_extents = Vector3(1400, 740, 1)
	particle_material.direction = Vector3(1.0, -0.035, 0.0)
	particle_material.spread = 8.0
	particle_material.initial_velocity_min = 5.0
	particle_material.initial_velocity_max = 13.0
	particle_material.gravity = Vector3.ZERO
	particle_material.scale_min = 0.45
	particle_material.scale_max = 1.35
	particle_material.color = Color(0.91, 0.65, 0.48, 0.26)
	particles.process_material = particle_material
	var dust_gradient := Gradient.new()
	dust_gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.62))
	dust_gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var dust_texture := GradientTexture2D.new()
	dust_texture.gradient = dust_gradient
	dust_texture.width = 8
	dust_texture.height = 8
	dust_texture.fill = GradientTexture2D.FILL_RADIAL
	dust_texture.fill_from = Vector2(0.5, 0.5)
	dust_texture.fill_to = Vector2(0.5, 0.05)
	particles.texture = dust_texture
	add_child(particles)

func _process(delta: float) -> void:
	GameManager.player_position = rover.global_position if rover.is_driving else player.global_position
	if not hud.is_modal_open() and float(GameManager.stats.get("health", 0.0)) > 0.0:
		autosave_elapsed += delta
		if autosave_elapsed >= AUTOSAVE_INTERVAL_SECONDS:
			autosave_elapsed = 0.0
			GameManager.save_game()
	if not fainted and float(GameManager.stats.get("health", 0.0)) <= 0.0:
		fainted = true
		survival_timer.stop()
		hud.show_choices("Sinal perdido", "A astronauta não consegue continuar. Reinicie a partir do último salvamento.", [
			{"label": "Reiniciar último salvamento", "action": Callable(self, "_reload_checkpoint"), "enabled": GameManager.save_exists()}
		])
	_update_interaction_prompt()

func _on_survival_timer_timeout() -> void:
	GameManager.advance_survival()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or event.keycode != KEY_E:
		return
	if hud.is_modal_open():
		return
	var target_id := _get_interaction_target()
	if target_id != "":
		if target_id == "rover":
			rover.toggle_drive(player)
		else:
			player.play_action_animation("interact")
			hud.on_world_interaction(target_id)

func _get_interaction_target() -> String:
	if rover.is_driving:
		return "rover"
	var target_id := ""
	var target_position := Vector2.ZERO
	match GameManager.tutorial_step:
		0:
			target_id = "cache"
			target_position = Vector2(1060, 650)
		3, 4:
			target_id = "vehicle"
			target_position = Vector2(930, 900)
		5:
			target_id = "camp"
			target_position = CAMP_POSITION
		_:
			# Cache remains interactable after tutorial for re-inspection
			if player.global_position.distance_to(Vector2(1060, 650)) <= INTERACTION_RADIUS:
				return "cache"
	if target_id != "" and player.global_position.distance_to(target_position) <= INTERACTION_RADIUS:
		return target_id
	if player.global_position.distance_to(rover.global_position) <= INTERACTION_RADIUS:
		return "rover"

	# Habitat door interaction
	if GameManager.structures.has("habitat") and GameManager.structures["habitat"]:
		if player.global_position.distance_to(HABITAT_POSITION) <= INTERACTION_RADIUS:
			return "habitat_door"

	# Resource node collection
	for node in RESOURCE_NODES:
		var node_id := str(node["id"])
		if node_id in collected_resources:
			continue
		if player.global_position.distance_to(Vector2(node["position"])) <= INTERACTION_RADIUS:
			return "resource_" + node_id

	return ""

func _update_interaction_prompt() -> void:
	if hud.is_modal_open():
		hud.set_interaction_prompt("")
		rover.set_prompt_active(false)
		return
	var target_id := _get_interaction_target()
	var prompt := ""
	if target_id == "cache":
		prompt = "E | Abrir baú de suprimentos"
	elif target_id == "vehicle":
		prompt = "E | Interagir com o rover"
	elif target_id == "camp":
		prompt = "E | Retornar ao acampamento"
	elif target_id == "rover":
		rover.set_prompt_active(true)
	elif target_id == "habitat_door":
		prompt = "E | Entrar no Habitat"
	elif target_id.begins_with("resource_"):
		prompt = "E | Coletar recurso"
	elif GameManager.tutorial_step == 5:
		prompt = "Retorne à zona central do acampamento"
	if target_id != "rover":
		rover.set_prompt_active(false, target_id == "vehicle")
	hud.set_interaction_prompt(prompt)

func _move_to_expedition() -> void:
	player.global_position = EXPEDITION_POSITION
	GameManager.player_position = EXPEDITION_POSITION

func _on_modal_visibility_changed(modal_visible: bool) -> void:
	player.set("controls_enabled", not modal_visible)
	survival_timer.paused = modal_visible
	if not modal_visible:
		GameManager.player_position = player.global_position

func _refresh_structures() -> void:
	for structure_id in structure_views:
		var structure_view: Node2D = structure_views[structure_id]
		var is_built := bool(GameManager.structures.get(structure_id, false))
		structure_view.call("set_state", is_built, selected_structure_preview == structure_id)

func _set_construction_preview(structure_id: String) -> void:
	selected_structure_preview = structure_id
	_refresh_structures()

func _setup_structure_views() -> void:
	var definitions := [
		{"id": "habitat", "position": Vector2(520, 540), "size": Vector2(180, 126)},
		{"id": "workshop", "position": Vector2(1180, 380), "size": Vector2(150, 112)},
		{"id": "warehouse", "position": Vector2(1460, 560), "size": Vector2(156, 112)},
		{"id": "greenhouse", "position": Vector2(760, 640), "size": Vector2(166, 112)},
		{"id": "solar_panel", "position": Vector2(1690, 760), "size": Vector2(184, 96)},
		{"id": "comm_antenna", "position": Vector2(1650, 220), "size": Vector2(112, 150)},
		{"id": "laboratory", "position": Vector2(1430, 720), "size": Vector2(154, 118)},
		{"id": "pet_shelter", "position": Vector2(650, 460), "size": Vector2(116, 88)},
		{"id": "miner", "position": Vector2(1180, 660), "size": Vector2(164, 112)}
	]
	var structure_layer := $StructureGhosts as Node2D
	for child in structure_layer.get_children():
		child.visible = false
	for definition in definitions:
		var structure_view := Node2D.new()
		structure_view.name = "%sView" % str(definition["id"]).capitalize()
		structure_view.set_script(STRUCTURE_VIEW_SCRIPT)
		structure_layer.add_child(structure_view)
		var structure_id := str(definition["id"])
		structure_views[structure_id] = structure_view
		structure_view.call(
			"configure",
			structure_id,
			definition["position"],
			definition["size"],
			bool(GameManager.structures.get(structure_id, false)),
			selected_structure_preview == structure_id
		)
	_refresh_structures()

func _reload_checkpoint() -> void:
	if GameManager.load_game():
		get_tree().reload_current_scene()
