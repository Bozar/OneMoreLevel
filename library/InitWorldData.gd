const InitDemo := preload("res://library/init/InitDemo.gd")
const InitKnight := preload("res://library/init/InitKnight.gd")
const InitCorruption := preload("res://library/init/InitCorruption.gd")

const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const KnightPCAction := preload("res://library/pc_action/KnightPCAction.gd")
const CorruptionPCAction := preload("res://library/pc_action/CorruptionPCAction.gd")

const DemoAI := preload("res://library/npc_ai/DemoAI.gd")
const KnightAI := preload("res://library/npc_ai/KnightAI.gd")
const CorruptionAI := preload("res://library/npc_ai/CorruptionAI.gd")

const DemoProgress := preload("res://library/game_progress/DemoProgress.gd")
const KnightProgress := preload("res://library/game_progress/KnightProgress.gd")
const CorruptionProgress := preload("res://library/game_progress/CorruptionProgress.gd")

const DemolHelp: String = "res://user/doc/demo.md"
const KnightHelp: String = "res://user/doc/knight.md"
const CorruptionHelp: String = "res://user/doc/corruption.md"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _world_data: Dictionary = {
	_new_WorldTag.DEMO: [
		InitDemo, DemoPCAction, DemoAI, DemoProgress, DemolHelp
	],
	_new_WorldTag.KNIGHT: [
		InitKnight, KnightPCAction, KnightAI, KnightProgress, KnightHelp
	],
	_new_WorldTag.CORRUPTION: [
		InitCorruption, CorruptionPCAction, CorruptionAI, CorruptionProgress,
		CorruptionHelp
	],
}


func get_world_template(world_tag: String) -> Game_WorldTemplate:
	return _world_data[world_tag][0]


func get_pc_action(world_tag: String) -> Game_PCActionTemplate:
	return _world_data[world_tag][1]


func get_enemy_ai(world_tag: String) -> Game_AITemplate:
	return _world_data[world_tag][2]


func get_progress(world_tag: String) -> Game_ProgressTemplate:
	return _world_data[world_tag][3]


func get_help(world_tag: String) -> String:
	var help_file: File = File.new()
	var load_path: String = _world_data[world_tag][4]

	var __ = help_file.open(load_path, File.READ)
	var text: String = help_file.get_as_text()
	help_file.close()

	return text
