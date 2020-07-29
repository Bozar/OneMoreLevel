extends Node2D
class_name Game_GameSetting


signal setting_loaded(setting)

var _new_SettingTemplate := preload("res://library/SettingTemplate.gd")

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _exe_path: String = "data/setting.gd"
var _res_path: String = "res://bin/data/setting.gd"


func load_setting() -> void:
	var setting_file: File = File.new()
	var load_path: String = ""
	var setting_data

	var wizard: bool
	var rng_seed: int
	var world_tag: String

	for i in [_exe_path, _res_path]:
		if setting_file.file_exists(i):
			load_path = i
			break
	if load_path == "":
		setting_data = null
	else:
		setting_data = load(load_path).new()

	wizard = _get_wizard(setting_data)
	rng_seed = _get_seed(setting_data)
	world_tag = _get_world(setting_data)

	emit_signal("setting_loaded", _new_SettingTemplate.new(
			wizard, rng_seed, world_tag))


func _get_wizard(setting) -> bool:
	if (setting == null) or (not "WIZARD_MODE" in setting):
		return false
	return setting.WIZARD_MODE


func _get_seed(setting) -> int:
	if (setting == null) or (not "SEED" in setting) or (setting.SEED < 1):
		return -1
	return setting.SEED


func _get_world(setting) -> String:
	if (setting == null) or (not "WORLD" in setting) \
			or (not setting.WORLD in _new_WorldTag.get_full_world_tag()):
		return ""
	return setting.WORLD
