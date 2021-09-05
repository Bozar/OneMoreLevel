extends Node2D
class_name Game_GameSetting


signal setting_loaded()
signal setting_saved(save_data)

const WIZARD := "wizard_mode"
const SEED := "rng_seed"
const INCLUDE_WORLD := "include_world"
const EXCLUDE_WORLD := "exclude_world"
const SHOW_FULL_MAP := "show_full_map"
const PALETTE := "palette"

const SETTING_EXE_PATH := "data/setting.json"
const SETTING_RES_PATH := "res://bin/setting.json"

const PALETTE_EXE_PATH := "data/"
const PALETTE_RES_PATH := "res://bin/"
const JSON_EXTENSION := ".json"

const TRANSFER_SCENE := "res://scene/transfer_data/TransferData.tscn"
const TRANSFER_NODE := "/root/TransferData"

var _wizard_mode: bool
var _rng_seed: int
var _include_world: Array
var _exclude_world: Array
var _show_full_map: bool
var _palette: Dictionary
var _json_parse_error: bool


func load_setting() -> void:
	var setting_data: Dictionary = {}
	var __
	var transfer: Game_TransferData
	var json_parser: Game_FileParser

	_json_parse_error = false
	for i in [SETTING_EXE_PATH, SETTING_RES_PATH]:
		if not Game_FileIOHelper.has_file(i):
			continue
		json_parser = Game_FileIOHelper.read_as_json(i)
		_json_parse_error = not json_parser.parse_success
		if json_parser.parse_success:
			setting_data = json_parser.output_json
			break

	_wizard_mode = _set_wizard_mode(setting_data)
	_rng_seed = _set_rng_seed(setting_data)
	_include_world = _set_include_world(setting_data)
	_exclude_world = _set_exclude_world(setting_data)
	_show_full_map = _set_show_full_map(setting_data)
	_palette = _set_palette(setting_data)

	if get_tree().root.has_node(TRANSFER_NODE):
		transfer = get_tree().root.get_node(TRANSFER_NODE)
		_rng_seed = transfer.rng_seed
		_include_world = [transfer.world_tag]

		get_tree().root.remove_child(transfer)
		transfer.queue_free()

	emit_signal("setting_loaded")


func save_setting(save_tag: int) -> void:
	var transfer: Game_TransferData

	if get_tree().root.has_node(TRANSFER_NODE):
		transfer = get_tree().root.get_node(TRANSFER_NODE)
	else:
		transfer = load(TRANSFER_SCENE).instance()
		get_tree().root.add_child(transfer)
	emit_signal("setting_saved", transfer, save_tag)


func get_wizard_mode() -> bool:
	return _wizard_mode


func get_rng_seed() -> int:
	return _rng_seed


func get_include_world() -> Array:
	return _include_world


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


func _set_include_world(setting) -> Array:
	var include: Array = []

	if setting.has(INCLUDE_WORLD) and (setting[INCLUDE_WORLD] is Array):
		include = setting[INCLUDE_WORLD]
	return include


func _set_exclude_world(setting) -> Array:
	var exclude: Array = [Game_WorldTag.DEMO]

	if setting.has(EXCLUDE_WORLD) and (setting[EXCLUDE_WORLD] is Array):
		exclude = setting[EXCLUDE_WORLD]
	return exclude


func _set_show_full_map(setting) -> bool:
	if setting.has(SHOW_FULL_MAP) and (setting[SHOW_FULL_MAP] is bool):
		return setting[SHOW_FULL_MAP]
	return false


func _set_palette(setting) -> Dictionary:
	var file_name: String = ""
	var json_parser: Game_FileParser

	if not (setting.has(PALETTE) and (setting[PALETTE] is String)):
		return {}

	file_name = setting[PALETTE]
	for i in [PALETTE_EXE_PATH, PALETTE_RES_PATH]:
		for j in ["", JSON_EXTENSION]:
			json_parser = Game_FileIOHelper.read_as_json(i + file_name + j)
			if json_parser.parse_success:
				return json_parser.output_json
	return {}
