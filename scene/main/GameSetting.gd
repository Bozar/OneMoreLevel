extends Node2D
class_name Game_GameSetting


signal setting_loaded()
signal setting_saved(save_data)

const WIZARD: String = "wizard_mode"
const SEED: String = "rng_seed"
const WORLD_TAG: String = "world_tag"
const EXCLUDE_WORLD: String = "exclude_world"

const EXE_PATH: String = "data/setting.json"
const RES_PATH: String = "res://bin/setting.json"

const TRANSFER_SCENE: String = "res://scene/transfer_data/TransferData.tscn"
const TRANSFER_NODE: String = "/root/TransferData"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _wizard_mode: bool
var _rng_seed: int
var _world_tag: String
var _exclude_world: Array
var _json_parse_error: bool


func load_setting() -> void:
	var setting_file: File = File.new()
	var load_path: String = ""
	var parse_result: JSONParseResult
	var setting_data: Dictionary
	var __
	var transfer: Game_TransferData

	for i in [EXE_PATH, RES_PATH]:
		if setting_file.file_exists(i):
			load_path = i
			break
	if load_path == "":
		setting_data = {}
	else:
		__ = setting_file.open(load_path, File.READ)
		parse_result = JSON.parse(setting_file.get_as_text())
		if parse_result.error == OK:
			setting_data = parse_result.get_result()
			_json_parse_error = false
		else:
			setting_data = {}
			_json_parse_error = true
		setting_file.close()

	_wizard_mode = _set_wizard_mode(setting_data)
	_rng_seed = _set_rng_seed(setting_data)
	_world_tag = _set_world_tag(setting_data)
	_exclude_world = _set_exclude_world(setting_data)

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


func get_json_parse_error() -> bool:
	return _json_parse_error


func _set_wizard_mode(setting) -> bool:
	if not setting.has(WIZARD):
		return false
	return setting[WIZARD] as bool


func _set_rng_seed(setting) -> int:
	var random: int

	if not setting.has(SEED):
		return 0
	random = setting[SEED] as int
	return 0 if random < 1 else random


func _set_world_tag(setting) -> String:
	var new_world: String = ""

	if setting.has(WORLD_TAG):
		new_world = setting[WORLD_TAG].to_lower()
		if not _new_WorldTag.is_valid_world_tag(new_world):
			new_world = ""
	return new_world


func _set_exclude_world(setting) -> Array:
	var exclude: Array = []

	if not setting.has(EXCLUDE_WORLD):
		return [_new_WorldTag.DEMO]

	exclude = setting[EXCLUDE_WORLD] as Array
	for i in range(exclude.size()):
		exclude[i] = exclude[i] as String
	return exclude
