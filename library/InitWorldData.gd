class_name Game_InitWorldData


const PLACEHOLDER := "%str%"

const INIT_PATH := "res://library/init/Init%str%.gd"
const ACTION_PATH := "res://library/pc_action/%str%PCAction.gd"
const AI_PATH := "res://library/npc_ai/%str%AI.gd"
const PROGRESS_PATH := "res://library/game_progress/%str%Progress.gd"
const HELP_PATH := "res://user/doc/%str%.md"

const GENERAL_HELP := "res://user/doc/general.md"
const KEY_BINDING_HELP := "res://user/doc/keybinding.md"


static func get_world_template(world_tag: String) -> Game_WorldTemplate:
	return _load_data(INIT_PATH, world_tag)


static func get_pc_action(world_tag: String) -> Game_PCActionTemplate:
	return _load_data(ACTION_PATH, world_tag)


static func get_enemy_ai(world_tag: String) -> Game_AITemplate:
	return _load_data(AI_PATH, world_tag)


static func get_progress(world_tag: String) -> Game_ProgressTemplate:
	return _load_data(PROGRESS_PATH, world_tag)


static func get_help(world_tag: String) -> Array:
	var world_name: String = Game_WorldTag.get_world_name(world_tag).to_lower()
	var dungeon: String = HELP_PATH.replace(PLACEHOLDER, world_name)
	var parse_file: Game_FileParser
	var result: Array = []

	for i in [dungeon, KEY_BINDING_HELP, GENERAL_HELP]:
		parse_file = Game_FileIOHelper.read_as_text(i)
		if parse_file.parse_success:
			result.push_back(parse_file.output_text)
		else:
			result.push_back("")
	return result


static func _load_data(file_path: String, world_tag: String):
	var world_name: String = Game_WorldTag.get_world_name(world_tag)
	var full_path: String = file_path.replace(PLACEHOLDER, world_name)

	return load(full_path)
