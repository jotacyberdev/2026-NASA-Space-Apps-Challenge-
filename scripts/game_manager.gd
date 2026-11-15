extends Node

signal state_changed

const SAVE_PATH := "user://mars_last_survivor.save"
const SURVIVAL_DRAIN_PER_HOUR := {
	"oxygen": 5.0,
	"energy": 3.0,
	"hunger": 2.0,
	"water": 3.5
}
const ZERO_STAT_DAMAGE_PER_HOUR := {
	"oxygen": 4.0,
	"hunger": 1.5,
	"water": 2.0
}
const INVENTORY_CAPACITY := 24
const MAX_STACK_SIZE := 99
const ITEM_NAMES := {
	"metal": "Metal",
	"polymer": "Polímero",
	"seeds": "Sementes",
	"rations": "Ração",
	"water_bottle": "Água engarrafada",
	"medkit": "Kit médico",
	"spare_parts": "Peças de reposição"
}
const BUILD_RECIPES := {
	"habitat": {"metal": 4, "polymer": 2},
	"greenhouse": {"metal": 2, "polymer": 2, "seeds": 2},
	"miner": {"metal": 4, "spare_parts": 2}
}
const OBJECTIVES := [
	"Abra o baú de suprimentos próximo à astronauta.",
	"Construa o Habitat nível 1 pelo menu Construção.",
	"Construa a Estufa nível 1 pelo menu Construção.",
	"Vá até o veículo e pressione E para iniciar a exploração.",
	"Escolha uma abordagem para concluir a exploração.",
	"Retorne à área do acampamento indicada no mapa.",
	"Construa a Mineradora nível 1 pelo menu Construção.",
    "Tutorial do Dia 1 concluído."
]

var player_name := "Astra"
var gender := "female"
var pet := "dog"
var difficulty := "normal"
var intro_skipped := false
var current_objective := "Acordar e revisar o acampamento."
var day := 1
var sol := 1
var current_time := "06:00"
var tutorial_step := 0
var cache_opened := false
var expedition_reward_claimed := false
var structures: Dictionary = {"habitat": false, "greenhouse": false, "miner": false}
var inventory: Array = []
var player_position := Vector2(980, 650)
var diary_read: Array = []
var collected_resources: Array = []

var stats: Dictionary = {
	"health": 100.0,
	"oxygen": 100.0,
	"energy": 100.0,
	"hunger": 100.0,
	"water": 100.0
}

func _ready() -> void:
	_reset_inventory()

func clamp_stat(value: float) -> float:
	return clamp(value, 0.0, 100.0)

func apply_stat_change(stat_name: String, amount: float) -> void:
	if stats.has(stat_name):
		var old_value := float(stats[stat_name])
		var new_value := clamp_stat(old_value + amount)
		if not is_equal_approx(old_value, new_value):
			stats[stat_name] = new_value
			state_changed.emit()

func begin_new_game(new_name: String, new_gender: String, new_pet: String, new_difficulty: String) -> void:
	reset_defaults()
	player_name = new_name.strip_edges()
	gender = new_gender if new_gender in ["male", "female"] else "female"
	pet = new_pet if new_pet in ["dog", "monkey"] else "dog"
	difficulty = new_difficulty if new_difficulty in ["easy", "normal", "hard"] else "normal"
	current_objective = OBJECTIVES[0]
	save_game()

func _reset_inventory() -> void:
	inventory.clear()
	for _slot_index in range(INVENTORY_CAPACITY):
		inventory.append({"id": "", "count": 0})

func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in inventory:
		if slot.get("id", "") == item_id:
			total += int(slot.get("count", 0))
	return total

func can_add_items(items: Dictionary) -> bool:
	var free_slots := 0
	var stack_space: Dictionary = {}
	for slot in inventory:
		var existing_item_id := str(slot.get("id", ""))
		var existing_count := int(slot.get("count", 0))
		if existing_item_id == "":
			free_slots += 1
		elif ITEM_NAMES.has(existing_item_id) and existing_count >= 0 and existing_count <= MAX_STACK_SIZE:
			stack_space[existing_item_id] = int(stack_space.get(existing_item_id, 0)) + MAX_STACK_SIZE - existing_count
		else:
			return false

	var required_slots := 0
	for item_id in items:
		var amount_value = items[item_id]
		if not ITEM_NAMES.has(item_id) or not (amount_value is int) or amount_value <= 0:
			return false
		var remaining_after_stacks: int = maxi(0, int(amount_value) - int(stack_space.get(item_id, 0)))
		required_slots += int(ceil(float(remaining_after_stacks) / MAX_STACK_SIZE))
	return required_slots <= free_slots

func add_item(item_id: String, amount: int = 1) -> bool:
	var items: Dictionary = {}
	items[item_id] = amount
	return add_items(items)

func add_items(items: Dictionary, emit_update: bool = true) -> bool:
	if items.is_empty() or not can_add_items(items):
		return false
	for item_id in items:
		_add_item_unchecked(str(item_id), int(items[item_id]))
	if emit_update:
		state_changed.emit()
	return true

func _add_item_unchecked(item_id: String, amount: int) -> void:
	var remaining := amount
	for slot in inventory:
		if slot.get("id", "") == item_id and int(slot.get("count", 0)) < MAX_STACK_SIZE:
			var added: int = min(remaining, MAX_STACK_SIZE - int(slot["count"]))
			slot["count"] = int(slot["count"]) + added
			remaining -= added
	for slot in inventory:
		if remaining <= 0:
			break
		if slot.get("id", "") == "":
			var added: int = min(remaining, MAX_STACK_SIZE)
			slot["id"] = item_id
			slot["count"] = added
			remaining -= added

func _add_items_unchecked(items: Dictionary) -> void:
	for item_id in items:
		_add_item_unchecked(str(item_id), int(items[item_id]))

func remove_item(item_id: String, amount: int = 1) -> bool:
	if not ITEM_NAMES.has(item_id) or amount <= 0 or get_item_count(item_id) < amount:
		return false
	_remove_item_unchecked(item_id, amount)
	state_changed.emit()
	return true

func collect_initial_cache() -> bool:
	if tutorial_step != 0:
		return false
	var supplies := {"metal": 10, "polymer": 4, "seeds": 2, "rations": 3, "water_bottle": 3, "medkit": 1}
	if not add_items(supplies, false):
		return false
	cache_opened = true
	tutorial_step = 1
	current_objective = OBJECTIVES[tutorial_step]
	state_changed.emit()
	save_game()
	return true

func is_cache_available() -> bool:
	return tutorial_step == 0

func can_build(structure_id: String) -> bool:
	if not BUILD_RECIPES.has(structure_id) or structures.get(structure_id, false):
		return false
	var required_step: int = int({"habitat": 1, "greenhouse": 2, "miner": 6}.get(structure_id, -1))
	if tutorial_step != required_step:
		return false
	for item_id in BUILD_RECIPES[structure_id]:
		if get_item_count(item_id) < int(BUILD_RECIPES[structure_id][item_id]):
			return false
	return true

func build_structure(structure_id: String) -> bool:
	if not can_build(structure_id):
		return false
	var recipe: Dictionary = BUILD_RECIPES[structure_id]
	for item_id in recipe:
		if get_item_count(item_id) < int(recipe[item_id]):
			return false
	for item_id in recipe:
		_remove_item_unchecked(item_id, int(recipe[item_id]))
	structures[structure_id] = true
	tutorial_step += 1
	current_objective = OBJECTIVES[tutorial_step]
	state_changed.emit()
	save_game()
	return true

func start_exploration() -> bool:
	if tutorial_step != 3:
		return false
	_set_tutorial_step(4)
	return true

func resolve_exploration(choice: String) -> bool:
	if tutorial_step != 4 or expedition_reward_claimed or choice not in ["careful", "fast"]:
		return false
	var reward := {"spare_parts": 2, "metal": 2}
	if not add_items(reward, false):
		return false
	expedition_reward_claimed = true
	if choice == "fast":
		stats["energy"] = clamp_stat(float(stats["energy"]) - 5.0)
	tutorial_step = 5
	current_objective = OBJECTIVES[tutorial_step]
	state_changed.emit()
	save_game()
	return true

func return_to_camp() -> bool:
	if tutorial_step != 5:
		return false
	_set_tutorial_step(6)
	return true

func collect_resource(node_id: String) -> bool:
	if node_id in collected_resources:
		return false
	var node_data = {
		"metal_scrap_1": {"item": "metal", "amount": 5},
		"metal_scrap_2": {"item": "metal", "amount": 5},
		"polymer_crystal_1": {"item": "polymer", "amount": 3},
		"polymer_crystal_2": {"item": "polymer", "amount": 3},
		"mineral_deposit_1": {"item": "metal", "amount": 8},
		"mineral_deposit_2": {"item": "metal", "amount": 8},
	}
	if not node_data.has(node_id):
		return false
	var data = node_data[node_id]
	var item_id := str(data["item"])
	var amount := int(data["amount"])
	if not add_items({item_id: amount}):
		return false
	collected_resources.append(node_id)
	state_changed.emit()
	save_game()
	return true

func restore_at_habitat() -> void:
	stats["oxygen"] = 100.0
	stats["energy"] = 100.0
	state_changed.emit()

func consume_item(item_id: String) -> bool:
	var effects := {"rations": {"hunger": 30.0}, "water_bottle": {"water": 30.0}, "medkit": {"health": 25.0}}
	if not effects.has(item_id) or get_item_count(item_id) < 1:
		return false
	var has_effect := false
	for stat_name in effects[item_id]:
		if float(stats[stat_name]) < 100.0 and float(effects[item_id][stat_name]) > 0.0:
			has_effect = true
			break
	if not has_effect:
		return false
	_remove_item_unchecked(item_id, 1)
	for stat_name in effects[item_id]:
		stats[stat_name] = clamp_stat(float(stats[stat_name]) + float(effects[item_id][stat_name]))
	state_changed.emit()
	return true

func _remove_item_unchecked(item_id: String, amount: int) -> void:
	var remaining := amount
	for slot in inventory:
		if slot.get("id", "") != item_id:
			continue
		var removed: int = min(remaining, int(slot["count"]))
		slot["count"] = int(slot["count"]) - removed
		remaining -= removed
		if int(slot["count"]) == 0:
			slot["id"] = ""
		if remaining == 0:
			return

func _set_tutorial_step(step: int) -> void:
	tutorial_step = clampi(step, 0, OBJECTIVES.size() - 1)
	current_objective = OBJECTIVES[tutorial_step]
	state_changed.emit()
	save_game()

func save_game() -> bool:
	var save_data := {
		"version": 1,
		"player_name": player_name,
		"gender": gender,
		"pet": pet,
		"difficulty": difficulty,
		"intro_skipped": intro_skipped,
		"current_objective": current_objective,
		"day": day,
		"sol": sol,
		"current_time": current_time,
		"tutorial_step": tutorial_step,
		"cache_opened": cache_opened,
		"expedition_reward_claimed": expedition_reward_claimed,
		"structures": structures,
		"inventory": inventory,
		"stats": stats,
		"player_position": [player_position.x, player_position.y],
		"diary_read": diary_read,
		"collected_resources": collected_resources
	}
	if not _is_valid_save_data(save_data):
		push_error("O estado atual da partida não passou pela validação de salvamento.")
		return false
	var temporary_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		push_error("Não foi possível abrir o arquivo temporário de salvamento: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(save_data))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("Falha ao gravar o arquivo temporário de salvamento.")
		return false

	var absolute_path := ProjectSettings.globalize_path(SAVE_PATH)
	var absolute_temporary_path := ProjectSettings.globalize_path(temporary_path)
	var absolute_backup_path := ProjectSettings.globalize_path(SAVE_PATH + ".bak")
	if FileAccess.file_exists(SAVE_PATH):
		var old_data := _read_valid_save(SAVE_PATH)
		if not old_data.is_empty():
			var old_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
			if old_file == null:
				push_error("Não foi possível ler o salvamento anterior para criar backup.")
				return false
			var old_content := old_file.get_as_text()
			old_file.close()
			var backup_file := FileAccess.open(SAVE_PATH + ".bak.tmp", FileAccess.WRITE)
			if backup_file == null:
				push_error("Não foi possível criar o backup do salvamento.")
				return false
			backup_file.store_string(old_content)
			backup_file.flush()
			var backup_error := backup_file.get_error()
			backup_file.close()
			if backup_error != OK:
				return false
			if FileAccess.file_exists(SAVE_PATH + ".bak"):
				DirAccess.remove_absolute(absolute_backup_path)
			if DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".bak.tmp"), absolute_backup_path) != OK:
				return false
		if DirAccess.remove_absolute(absolute_path) != OK:
			return false
	if DirAccess.rename_absolute(absolute_temporary_path, absolute_path) != OK:
		push_error("Não foi possível substituir o salvamento principal.")
		if FileAccess.file_exists(SAVE_PATH + ".bak"):
			DirAccess.copy_absolute(absolute_backup_path, absolute_path)
		return false
	return true

func load_game() -> bool:
	var data := _read_valid_save(SAVE_PATH)
	if data.is_empty():
		data = _read_valid_save(SAVE_PATH + ".bak")
	if data.is_empty():
		return false

	player_name = data["player_name"]
	gender = data["gender"]
	pet = data["pet"]
	difficulty = data["difficulty"]
	intro_skipped = data["intro_skipped"]
	day = data["day"]
	sol = data["sol"]
	current_time = data["current_time"]
	tutorial_step = data["tutorial_step"]
	current_objective = OBJECTIVES[tutorial_step]
	cache_opened = data["cache_opened"]
	expedition_reward_claimed = data["expedition_reward_claimed"]
	structures = data["structures"]
	stats = data["stats"]
	inventory = data["inventory"]
	player_position = data["player_position"]
	diary_read = data["diary_read"]
	collected_resources = data["collected_resources"]
	state_changed.emit()
	return true

func _read_valid_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary) or not _is_valid_save_data(parsed):
		return {}
	return _normalize_save_data(parsed)

func _is_valid_save_data(data: Dictionary) -> bool:
	var required_keys := ["version", "player_name", "gender", "pet", "difficulty", "intro_skipped", "current_objective", "day", "sol", "current_time", "tutorial_step", "cache_opened", "expedition_reward_claimed", "structures", "inventory", "stats", "player_position", "diary_read", "collected_resources"]
	for key in required_keys:
		if not data.has(key):
			return false
	if not (data["version"] is int) or int(data["version"]) != 1:
		return false
	if not (data["player_name"] is String) or str(data["player_name"]).strip_edges().length() < 2 or str(data["player_name"]).length() > 16:
		return false
	if not (data["current_objective"] is String):
		return false
	if not (data["current_time"] is String):
		return false
	if not ["male", "female"].has(data["gender"]) or not ["dog", "monkey"].has(data["pet"]) or not ["easy", "normal", "hard"].has(data["difficulty"]):
		return false
	if not (data["intro_skipped"] is bool) or not (data["cache_opened"] is bool) or not (data["expedition_reward_claimed"] is bool):
		return false
	if not (data["day"] is int) or int(data["day"]) < 1 or not (data["sol"] is int) or int(data["sol"]) < 1:
		return false
	if not (data["tutorial_step"] is int) or int(data["tutorial_step"]) < 0 or int(data["tutorial_step"]) >= OBJECTIVES.size():
		return false
	var time_parts := str(data["current_time"]).split(":")
	if time_parts.size() != 2 or not time_parts[0].is_valid_int() or not time_parts[1].is_valid_int():
		return false
	if int(time_parts[0]) < 0 or int(time_parts[0]) > 23 or int(time_parts[1]) < 0 or int(time_parts[1]) > 59:
		return false
	if not (data["structures"] is Dictionary) or not (data["inventory"] is Array) or data["inventory"].size() != INVENTORY_CAPACITY:
		return false
	if not (data["stats"] is Dictionary) or not (data["player_position"] is Array) or data["player_position"].size() != 2 or not (data["diary_read"] is Array):
		return false
	for structure_id in ["habitat", "greenhouse", "miner"]:
		if not data["structures"].has(structure_id) or not (data["structures"][structure_id] is bool):
			return false
	var saved_step: int = int(data["tutorial_step"])
	if bool(data["cache_opened"]) != (saved_step >= 1):
		return false
	if bool(data["structures"]["habitat"]) != (saved_step >= 2):
		return false
	if bool(data["structures"]["greenhouse"]) != (saved_step >= 3):
		return false
	if bool(data["expedition_reward_claimed"]) != (saved_step >= 5):
		return false
	if bool(data["structures"]["miner"]) != (saved_step >= 7):
		return false
	for stat_name in ["health", "oxygen", "energy", "hunger", "water"]:
		if not data["stats"].has(stat_name) or not (data["stats"][stat_name] is float or data["stats"][stat_name] is int):
			return false
		if float(data["stats"][stat_name]) < 0.0 or float(data["stats"][stat_name]) > 100.0:
			return false
	for slot in data["inventory"]:
		if not (slot is Dictionary) or not slot.has("id") or not slot.has("count"):
			return false
		var item_id := str(slot["id"])
		var count = slot["count"]
		if not (count is int) or int(count) < 0 or int(count) > MAX_STACK_SIZE:
			return false
		if item_id != "" and (not ITEM_NAMES.has(item_id) or int(count) == 0):
			return false
		if item_id == "" and int(count) != 0:
			return false
	for position_value in data["player_position"]:
		if not (position_value is float or position_value is int):
			return false
	for read_entry in data["diary_read"]:
		if not (read_entry is String) or str(read_entry).is_empty():
			return false
	var position := Vector2(float(data["player_position"][0]), float(data["player_position"][1]))
	if position.x < 0.0 or position.x > 2000.0 or position.y < 0.0 or position.y > 1200.0:
		return false
	return true

func _normalize_save_data(data: Dictionary) -> Dictionary:
	var normalized := data.duplicate(true)
	var objective_index := clampi(int(normalized["tutorial_step"]), 0, OBJECTIVES.size() - 1)
	normalized["current_objective"] = OBJECTIVES[objective_index]
	normalized["player_position"] = Vector2(float(data["player_position"][0]), float(data["player_position"][1]))
	normalized["stats"] = data["stats"].duplicate(true)
	for stat_name in normalized["stats"]:
		normalized["stats"][stat_name] = clamp_stat(float(normalized["stats"][stat_name]))
	return normalized

func advance_survival(minutes: int = 1) -> void:
	if minutes <= 0:
		return
	var difficulty_multiplier := _get_difficulty_multiplier()
	for stat_name in SURVIVAL_DRAIN_PER_HOUR:
		var drain_per_minute: float = SURVIVAL_DRAIN_PER_HOUR[stat_name] / 60.0
		stats[stat_name] = clamp_stat(float(stats[stat_name]) - drain_per_minute * minutes * difficulty_multiplier)

	for stat_name in ZERO_STAT_DAMAGE_PER_HOUR:
		if float(stats[stat_name]) <= 0.0:
			var damage_per_minute: float = ZERO_STAT_DAMAGE_PER_HOUR[stat_name] / 60.0
			stats["health"] = clamp_stat(float(stats["health"]) - damage_per_minute * minutes * difficulty_multiplier)

	_advance_clock(minutes)
	state_changed.emit()

func _get_difficulty_multiplier() -> float:
	match difficulty:
		"easy":
			return 0.5
		"hard":
			return 1.5
		_:
			return 1.0

func _advance_clock(minutes: int) -> void:
	var time_parts := current_time.split(":")
	var total_minutes := int(time_parts[0]) * 60 + int(time_parts[1]) + minutes
	var days_elapsed := floori(float(total_minutes) / 1440.0)
	total_minutes %= 1440
	day += days_elapsed
	sol += days_elapsed
	current_time = "%02d:%02d" % [floori(float(total_minutes) / 60.0), total_minutes % 60]

func save_exists() -> bool:
	return not _read_valid_save(SAVE_PATH).is_empty() or not _read_valid_save(SAVE_PATH + ".bak").is_empty()

func reset_defaults() -> void:
	player_name = "Astra"
	gender = "female"
	pet = "dog"
	difficulty = "normal"
	intro_skipped = false
	current_objective = "Acordar e revisar o acampamento."
	day = 1
	sol = 1
	current_time = "06:00"
	tutorial_step = 0
	cache_opened = false
	expedition_reward_claimed = false
	structures = {"habitat": false, "greenhouse": false, "miner": false}
	player_position = Vector2(980, 650)
	diary_read.clear()
	_reset_inventory()
	collected_resources.clear()
	stats = {
		"health": 100.0,
		"oxygen": 100.0,
		"energy": 100.0,
		"hunger": 100.0,
		"water": 100.0
	}
	state_changed.emit()
