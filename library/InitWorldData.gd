const PLACEHOLDER: String = "%str%"

const INIT_PATH: String = "res://library/init/Init%str%.gd"
const ACTION_PATH: String = "res://library/pc_action/%str%PCAction.gd"
const AI_PATH: String = "res://library/npc_ai/%str%AI.gd"
const PROGRESS_PATH: String = "res://library/game_progress/%str%Progress.gd"
const HELP_PATH: String = "res://user/doc/%str%.md"

const GENERAL_HELP: String = "res://user/doc/general.md"
const KEY_BINDING_HELP: String = "res://user/doc/keybinding.md"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _world_to_file: Dictionary = {
	_new_WorldTag.DEMO: "Demo",
	_new_WorldTag.KNIGHT: "Knight",
	_new_WorldTag.DESERT: "Desert",
	_new_WorldTag.STYX: "Styx",
	_new_WorldTag.MIRROR: "Mirror",
	_new_WorldTag.BALLOON: "Balloon",
	_new_WorldTag.FROG: "Frog",
}


func get_world_template(world_tag: String) -> Game_WorldTemplate:
	return _load_data(INIT_PATH, world_tag)


func get_pc_action(world_tag: String) -> Game_PCActionTemplate:
	return _load_data(ACTION_PATH, world_tag)


func get_enemy_ai(world_tag: String) -> Game_AITemplate:
	return _load_data(AI_PATH, world_tag)


func get_progress(world_tag: String) -> Game_ProgressTemplate:
	return _load_data(PROGRESS_PATH, world_tag)


func get_help(world_tag: String) -> Array:
	var dungeon: String = HELP_PATH.replace(PLACEHOLDER,
			_world_to_file[world_tag].to_lower())

	return [
		_read_file(dungeon),
		_read_file(KEY_BINDING_HELP),
		_read_file(GENERAL_HELP)
	]


func _read_file(file_path: String) -> String:
	var new_file: File = File.new()
	var __ = new_file.open(file_path, File.READ)
	var text: String = new_file.get_as_text()
	new_file.close()

	return text


func _load_data(file_path: String, world_tag: String):
	var full_path: String = file_path.replace(PLACEHOLDER,
			_world_to_file[world_tag])
	return load(full_path)
