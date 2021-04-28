extends Node2D
class_name Game_GameSetting


signal setting_loaded()
signal setting_saved(save_data)

const WIZARD: String = "wizard_mode"
const SEED: String = "rng_seed"
const WORLD_TAG: String = "world_tag"
const EXCLUDE_WORLD: String = "exclude_world"
const SHOW_FULL_MAP: String = "show_full_map"
const PALETTE: String = "palette"

const SETTING_EXE_PATH: String = "data/setting.json"
const SETTING_RES_PATH: String = "res://bin/setting.json"

const PALETTE_EXE_PATH: String = "data/"
const PALETTE_RES_PATH: String = "res://bin/"
const JSON_EXTENSION: String = ".json"

const TRANSFER_SCENE: String = "res://scene/transfer_data/TransferData.tscn"
const TRANSFER_NODE: String = "/root/TransferData"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _wizard_mode: bool
var _rng_seed: int
var _world_tag: String
var _exclude_world: Array
var _show_full_map: bool
var _palette: Dictionary
var _json_parse_error: bool


func load_setting() -> void:
	var setting_file: File = File.new()
	var load_path: String = ""
	var setting_data: Dictionary
	var __
	var transfer: Game_TransferData

	for i in [SETTING_EXE_PATH, SETTING_RES_PATH]:
		if setting_file.file_exists(i):
			load_path = i
			break
	if load_path == "":
		setting_data = {}
	else:
		_json_parse_error = not _try_read_file(load_path, setting_file,
				setting_data)

	_wizard_mode = _set_wizard_mode(setting_data)
	_rng_seed = _set_rng_seed(setting_data)
	_world_tag = _set_world_tag(setting_data)
	_exclude_world = _set_exclude_world(setting_data)
	_show_full_map = _set_show_full_map(setting_data)
	_palette = _set_palette(setting_data)

	if get_tree().root.has_node(TRANSFER_NODE):
		transfer = get_tree().root.get_node(TRANSFER_NODE)
		_rng_seed = transfer.rng_seed
		_world_tag = transfer.world_tag

		get_tree().root.remove_child(transfer)
		transfer.queue_free()

	emit_signal("setting_loaded")


func save_setting() -> void:
	var transfer: Game_TransferData = load(TRANSFER_SCENE).instance()

	emit_signal("setting_saved", transfer)
	get_tree().root.add_child(transfer)


func get_wizard_mode() -> bool:
	return _wizard_mode


func get_rng_seed() -> int:
	return _rng_seed


func get_world_tag() -> String:
	return _world_tag


func get_exclude_world() -> Array:
	return _exclude_world


func get_show_full_map() -> bool:
	return _show_full_map


func get_palette() -> Dictionary:
	return _palette


func get_json_parse_error() -> bool:
	return _json_parse_error


func _set_wizard_mode(setting) -> bool:
	if setting.has(WIZARD) and (setting[WIZARD] is bool):
		return setting[WIZARD]
	return false


func _set_rng_seed(setting) -> int:
	var random: int

	if setting.has(SEED) and (setting[SEED] is float):
		random = setting[SEED] as int
		return 0 if random < 1 else random
	return 0


func _set_world_tag(setting) -> String:
	var new_world: String = ""

	if setting.has(WORLD_TAG) and (setting[WORLD_TAG] is String):
		new_world = setting[WORLD_TAG].to_lower()
		if not _new_WorldTag.is_valid_world_tag(new_world):
			new_world = ""
	return new_world


func _set_exclude_world(setting) -> Array:
	var exclude: Array = []

	if setting.has(EXCLUDE_WORLD) and (setting[EXCLUDE_WORLD] is Array):
		exclude = setting[EXCLUDE_WORLD]
		for i in range(exclude.size()):
			if exclude[i] is String:
				exclude[i] = (exclude[i]).to_lower()
		return exclude
	return [_new_WorldTag.DEMO]


func _set_show_full_map(setting) -> bool:
	if setting.has(SHOW_FULL_MAP) and (setting[SHOW_FULL_MAP] is bool):
		return setting[SHOW_FULL_MAP]
	return false


func _set_palette(setting) -> Dictionary:
	var palette_file: File = File.new()
	var load_path: String = ""
	var file_name: String = ""
	var read_palette: Dictionary = {}

	if not (setting.has(PALETTE) and (setting[PALETTE] is String)):
		return {}

	file_name = setting[PALETTE]
	for i in [PALETTE_EXE_PATH, PALETTE_RES_PATH]:
		for j in ["", JSON_EXTENSION]:
			if palette_file.file_exists(i + file_name + j):
				load_path = i + file_name + j
				break
		if load_path != "":
			break
	if load_path == "":
		return {}
	elif _try_read_file(load_path, palette_file, read_palette):
		return read_palette
	return {}


func _try_read_file(load_path: String, read_this: File,
			out__get_content: Dictionary) -> bool:
	var __ = read_this.open(load_path, File.READ)
	var try_parse: JSONParseResult
	var save_result: Dictionary
	var parse_success: bool = false

	out__get_content.clear()
	try_parse= JSON.parse(read_this.get_as_text())
	if try_parse.error == OK:
		parse_success = true
		save_result = try_parse.get_result()
		for i in save_result.keys():
			out__get_content[i] = save_result[i]

	read_this.close()
	return parse_success
