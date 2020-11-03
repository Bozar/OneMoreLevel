const InitDemo := preload("res://library/init/InitDemo.gd")
const InitKnight := preload("res://library/init/InitKnight.gd")
const InitDesert := preload("res://library/init/InitDesert.gd")
const InitStyx := preload("res://library/init/InitStyx.gd")
const InitMirror := preload("res://library/init/InitMirror.gd")
const InitBalloon := preload("res://library/init/InitBalloon.gd")

const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const KnightPCAction := preload("res://library/pc_action/KnightPCAction.gd")
const DesertPCAction := preload("res://library/pc_action/DesertPCAction.gd")
const StyxPCAction := preload("res://library/pc_action/StyxPCAction.gd")
const MirrorPCAction := preload("res://library/pc_action/MirrorPCAction.gd")
const BalloonPCAction := preload("res://library/pc_action/BalloonPCAction.gd")

const DemoAI := preload("res://library/npc_ai/DemoAI.gd")
const KnightAI := preload("res://library/npc_ai/KnightAI.gd")
const DesertAI := preload("res://library/npc_ai/DesertAI.gd")
const StyxAI := preload("res://library/npc_ai/StyxAI.gd")
const MirrorAI := preload("res://library/npc_ai/MirrorAI.gd")
const BalloonAI := preload("res://library/npc_ai/BalloonAI.gd")

const DemoProgress := preload("res://library/game_progress/DemoProgress.gd")
const KnightProgress := preload("res://library/game_progress/KnightProgress.gd")
const DesertProgress := preload("res://library/game_progress/DesertProgress.gd")
const StyxProgress := preload("res://library/game_progress/StyxProgress.gd")
const MirrorProgress := preload("res://library/game_progress/MirrorProgress.gd")
const BalloonProgress := preload("res://library/game_progress/BalloonProgress.gd")

const GeneralHelp: String = "res://user/doc/general.md"
const KeyBindingHelp: String = "res://user/doc/keybinding.md"
const DemoHelp: String = "res://user/doc/demo.md"
const KnightHelp: String = "res://user/doc/knight.md"
const DesertHelp: String = "res://user/doc/desert.md"
const StyxHelp: String = "res://user/doc/styx.md"
const MirrorHelp: String = "res://user/doc/mirror.md"
const BalloonHelp: String = "res://user/doc/balloon.md"

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _world_data: Dictionary = {
	_new_WorldTag.DEMO: [
		InitDemo, DemoPCAction, DemoAI, DemoProgress, DemoHelp
	],
	_new_WorldTag.KNIGHT: [
		InitKnight, KnightPCAction, KnightAI, KnightProgress, KnightHelp
	],
	_new_WorldTag.DESERT: [
		InitDesert, DesertPCAction, DesertAI, DesertProgress,
		DesertHelp
	],
	_new_WorldTag.STYX: [
		InitStyx, StyxPCAction, StyxAI, StyxProgress, StyxHelp
	],
	_new_WorldTag.MIRROR: [
		InitMirror, MirrorPCAction, MirrorAI, MirrorProgress, MirrorHelp
	],
	_new_WorldTag.BALLOON: [
		InitBalloon, BalloonPCAction, BalloonAI, BalloonProgress, BalloonHelp
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


func get_help(world_tag: String) -> Array:
	var dungeon: String = _world_data[world_tag][4]

	return [
		_read_file(dungeon),
		_read_file(KeyBindingHelp),
		_read_file(GeneralHelp)
	]


func _read_file(file_path: String) -> String:
	var new_file: File = File.new()
	var __ = new_file.open(file_path, File.READ)
	var text: String = new_file.get_as_text()
	new_file.close()

	return text
