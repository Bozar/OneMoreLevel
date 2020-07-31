extends Node2D
class_name Game_GameSetting


signal setting_loaded(setting)

const WIZARD: String = "wizard_mode"
const SEED: String = "rng_seed"
const WORLD: String = "world_tag"

const EXE_PATH: String = "data/setting.json"
const RES_PATH: String = "res://bin/data/setting.json"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()


class PlayerSetting extends Resource:


	var wizard_mode: bool setget set_wizard_mode, get_wizard_mode
	var rng_seed: int setget set_rng_seed, get_rng_seed
	var world_tag: String setget set_world_tag, get_world_tag


	func _init(wizard: bool, random: int, world: String) -> void:
		wizard_mode = wizard
		rng_seed = random
		world_tag = world


	func get_wizard_mode() -> bool:
		return wizard_mode


	func set_wizard_mode(__) -> void:
		return


	func get_rng_seed() -> int:
		return rng_seed


	func set_rng_seed(__) -> void:
		return


	func get_world_tag() -> String:
		return world_tag


	func set_world_tag(__) -> void:
		return


func load_setting() -> void:
	var setting_file: File = File.new()
	var load_path: String = ""
	var setting_data: Dictionary
	var __

	var wizard: bool
	var world: String
	var random: int

	for i in [EXE_PATH, RES_PATH]:
		if setting_file.file_exists(i):
			load_path = i
			break
	if load_path == "":
		setting_data = {}
	else:
		__ = setting_file.open(load_path, File.READ)
		setting_data = JSON.parse(setting_file.get_as_text()).get_result()
		setting_file.close()

	wizard = _get_wizard(setting_data)
	random = _get_seed(setting_data)
	world = _get_world(setting_data)

	emit_signal("setting_loaded", PlayerSetting.new(wizard, random, world))


func _get_wizard(setting) -> bool:
	if not setting.has(WIZARD):
		return false
	return setting[WIZARD] as bool


func _get_seed(setting) -> int:
	var random: int

	if not setting.has(SEED):
		return -1

	random = setting[SEED] as int
	if random < 1:
		return -1
	return random


func _get_world(setting) -> String:
	if not setting.has(WORLD):
		return ""
	if not _new_WorldTag.is_valid_world_tag(setting[WORLD]):
		return ""
	return setting[WORLD] as String
