class_name Game_InitWorldData


const WORLD_PLACEHOLDER := "%str%"
const HINT_PLACEHOLDER := "[INPUT_HINT]\n"

const INIT_PATH := "res://library/init/Init%str%.gd"
const ACTION_PATH := "res://library/pc_action/%str%PCAction.gd"
const AI_PATH := "res://library/npc_ai/%str%AI.gd"
const PROGRESS_PATH := "res://library/game_progress/%str%Progress.gd"
const HELP_PATH := "res://user/doc/%str%.md"

const GENERAL_HELP := "res://user/doc/general.md"
const KEY_BINDING_HELP := "res://user/doc/keybinding.md"

const HINT_DUNGEON := "res://user/doc/hint_dungeon.md"
const HINT_GENERAL := "res://user/doc/hint_general.md"
const HINT_KEY_BINDING := "res://user/doc/hint_keybinding.md"


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
	var dungeon: String = HELP_PATH.replace(WORLD_PLACEHOLDER, world_name)
	var parse_help := [
		Game_FileIOHelper.read_as_text(dungeon),
		Game_FileIOHelper.read_as_text(KEY_BINDING_HELP),
		Game_FileIOHelper.read_as_text(GENERAL_HELP),
	]
	var parse_hint := [
		Game_FileIOHelper.read_as_text(HINT_DUNGEON),
		Game_FileIOHelper.read_as_text(HINT_KEY_BINDING),
		Game_FileIOHelper.read_as_text(HINT_GENERAL),
	]
	var help_text: String
	var hint_text: String
	var result := []

	for i in parse_help.size():
		if parse_help[i].parse_success and parse_hint[i].parse_success:
			hint_text = parse_hint[i].output_text
			help_text = parse_help[i].output_text
			help_text = help_text.replace(HINT_PLACEHOLDER, hint_text)
			result.push_back(help_text)
		else:
			result.push_back("")
	return result


static func _load_data(file_path: String, world_tag: String):
	var world_name: String = Game_WorldTag.get_world_name(world_tag)
	var full_path: String = file_path.replace(WORLD_PLACEHOLDER, world_name)

	return load(full_path)
