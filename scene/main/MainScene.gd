extends "res://library/RootNodeTemplate.gd"


const INIT_WORLD: String = "InitWorld"
const PLAYER_INPUT: String = "PlayerInput"
const HELP_INPUT: String = "HelpInput"
const ENEMY_AI: String = "EnemyAI"
const SCHEDULE: String = "Schedule"
const DUNGEON: String = "DungeonBoard"
const CREATE_OBJECT: String = "CreateObject"
const REMOVE_OBJECT: String = "RemoveObject"
const RANDOM: String = "RandomNumber"
const OBJECT_DATA: String = "ObjectData"
const SWITCH_SPRITE: String = "SwitchSprite"
const SWITCH_SCREEN: String = "SwitchScreen"
const DANGER_ZONE: String = "DangerZone"
const END_GAME: String = "EndGame"
const COUNT_DOWN: String = "CountDown"
const GAME_PROGRESS: String = "GameProgress"
const GAME_SETTING: String = "GameSetting"
const SIDEBAR_GUI: String = "MainGUI/SidebarVBox"
const HELP_GUI: String = "HelpGUI/HelpVScroll"

const SIGNAL_BIND: Array = [
	[
		"sprite_created", "_on_CreateObject_sprite_created",
		CREATE_OBJECT,
		PLAYER_INPUT, ENEMY_AI, SCHEDULE, DUNGEON, GAME_PROGRESS,
	],
	[
		"world_selected", "_on_InitWorld_world_selected",
		INIT_WORLD,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR_GUI, GAME_PROGRESS, HELP_GUI,
	],
	[
		"turn_started", "_on_Schedule_turn_started",
		SCHEDULE,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR_GUI, COUNT_DOWN, GAME_PROGRESS,
	],
	[
		"turn_ended", "_on_Schedule_turn_ended",
		SCHEDULE,
		COUNT_DOWN, GAME_PROGRESS,
	],
	[
		"sprite_removed", "_on_RemoveObject_sprite_removed",
		REMOVE_OBJECT,
		DUNGEON, SCHEDULE, OBJECT_DATA, ENEMY_AI, GAME_PROGRESS,
	],
	[
		"game_is_over", "_on_EndGame_game_is_over",
		END_GAME,
		SCHEDULE, PLAYER_INPUT, SIDEBAR_GUI, GAME_PROGRESS,
	],
	[
		"setting_loaded", "_on_GameSetting_setting_loaded",
		GAME_SETTING,
		RANDOM,
	],
	[
		"screen_switched", "_on_SwitchScreen_screen_switched",
		SWITCH_SCREEN,
		PLAYER_INPUT, CREATE_OBJECT, SIDEBAR_GUI, HELP_INPUT, HELP_GUI,
	],
	# [
	# 	"enemy_warned", "_on_EnemyAI_enemy_warned",
	# 	ENEMY_AI,
	# 	MODELINE,
	# ],
]

const NODE_REF: Array = [
	[
		"_ref_DungeonBoard",
		DUNGEON,
		PLAYER_INPUT, REMOVE_OBJECT, ENEMY_AI, GAME_PROGRESS, SIDEBAR_GUI,
	],
	[
		"_ref_Schedule",
		SCHEDULE,
		PLAYER_INPUT, ENEMY_AI, GAME_PROGRESS, INIT_WORLD,
	],
	[
		"_ref_RemoveObject",
		REMOVE_OBJECT,
		PLAYER_INPUT, ENEMY_AI, GAME_PROGRESS,
	],
	[
		"_ref_RandomNumber",
		RANDOM,
		INIT_WORLD, PLAYER_INPUT, ENEMY_AI, SIDEBAR_GUI, GAME_PROGRESS,
	],
	[
		"_ref_ObjectData",
		OBJECT_DATA,
		ENEMY_AI, SWITCH_SPRITE, PLAYER_INPUT, GAME_PROGRESS,
	],
	[
		"_ref_SwitchSprite",
		SWITCH_SPRITE,
		ENEMY_AI, PLAYER_INPUT, GAME_PROGRESS,
	],
	[
		"_ref_DangerZone",
		DANGER_ZONE,
		ENEMY_AI, PLAYER_INPUT, SIDEBAR_GUI, GAME_PROGRESS, INIT_WORLD,
	],
	[
		"_ref_EndGame",
		END_GAME,
		ENEMY_AI, PLAYER_INPUT, COUNT_DOWN, GAME_PROGRESS,
	],
	[
		"_ref_CountDown",
		COUNT_DOWN,
		SIDEBAR_GUI, PLAYER_INPUT, ENEMY_AI,
	],
	[
		"_ref_CreateObject",
		CREATE_OBJECT,
		INIT_WORLD, GAME_PROGRESS, ENEMY_AI, PLAYER_INPUT,
	],
	[
		"_ref_GameSetting",
		GAME_SETTING,
		INIT_WORLD, PLAYER_INPUT, SIDEBAR_GUI, RANDOM,
	],
	[
		"_ref_SwitchScreen",
		SWITCH_SCREEN,
		PLAYER_INPUT, HELP_INPUT,
	],
	[
		"_ref_HelpVScroll",
		HELP_GUI,
		HELP_INPUT,
	],
]


func _init().(SIGNAL_BIND, NODE_REF) -> void:
	pass
