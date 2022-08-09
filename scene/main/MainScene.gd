extends Game_RootNodeTemplate


const INIT_WORLD := "InitWorld"
const PLAYER_INPUT := "PlayerInput"
const HELP_INPUT := "HelpInput"
const ENEMY_AI := "EnemyAI"
const SCHEDULE := "Schedule"
const DUNGEON := "DungeonBoard"
const CREATE_OBJECT := "CreateObject"
const REMOVE_OBJECT := "RemoveObject"
const RANDOM := "RandomNumber"
const OBJECT_DATA := "ObjectData"
const SWITCH_SPRITE := "SwitchSprite"
const SWITCH_SCREEN := "SwitchScreen"
const DANGER_ZONE := "DangerZone"
const END_GAME := "EndGame"
const COUNT_DOWN := "CountDown"
const GAME_PROGRESS := "GameProgress"
const GAME_SETTING := "GameSetting"
const PALETTE := "Palette"
const SIDEBAR_GUI := "MainGUI/SidebarVBox"
const HELP_GUI := "HelpGUI/HelpVScroll"
const DEBUG_GUI := "DebugGUI/DebugVBox"
const DEBUG_INPUT := "DebugInput"

const SIGNAL_BIND := [
	[
		"sprite_created", "_on_CreateObject_sprite_created",
		CREATE_OBJECT,
		PLAYER_INPUT, ENEMY_AI, SCHEDULE, DUNGEON, GAME_PROGRESS, OBJECT_DATA,
	],
	[
		"world_selected", "_on_InitWorld_world_selected",
		INIT_WORLD,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR_GUI, GAME_PROGRESS, HELP_GUI,
		HELP_INPUT, DEBUG_GUI,
	],
	[
		"first_turn_starting", "_on_Schedule_first_turn_starting",
		SCHEDULE,
		GAME_PROGRESS,
	],
	[
		"first_turn_started", "_on_Schedule_first_turn_started",
		SCHEDULE,
		PLAYER_INPUT,
	],
	[
		"turn_starting", "_on_Schedule_turn_starting",
		SCHEDULE,
		GAME_PROGRESS,
	],
	[
		"turn_started", "_on_Schedule_turn_started",
		SCHEDULE,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR_GUI, COUNT_DOWN,
	],
	[
		"turn_ending", "_on_Schedule_turn_ending",
		SCHEDULE,
		GAME_PROGRESS,
	],
	[
		"turn_ended", "_on_Schedule_turn_ended",
		SCHEDULE,
		COUNT_DOWN,
	],
	[
		"sprite_removed", "_on_RemoveObject_sprite_removed",
		REMOVE_OBJECT,
		DUNGEON, SCHEDULE, OBJECT_DATA, ENEMY_AI, GAME_PROGRESS, PLAYER_INPUT,
	],
	[
		"game_over", "_on_EndGame_game_over",
		END_GAME,
		SCHEDULE, PLAYER_INPUT, SIDEBAR_GUI, GAME_PROGRESS,
	],
	[
		"setting_loaded", "_on_GameSetting_setting_loaded",
		GAME_SETTING,
		RANDOM, PALETTE,
	],
	[
		"setting_saved", "_on_GameSetting_setting_saved",
		GAME_SETTING,
		RANDOM, INIT_WORLD,
	],
	[
		"screen_switched", "_on_SwitchScreen_screen_switched",
		SWITCH_SCREEN,
		PLAYER_INPUT, CREATE_OBJECT, SIDEBAR_GUI, HELP_INPUT, HELP_GUI,
		DEBUG_GUI, DEBUG_INPUT,
	],
	# [
	# 	"enemy_warned", "_on_EnemyAI_enemy_warned",
	# 	ENEMY_AI,
	# 	MODELINE,
	# ],
]

const NODE_REF := [
	[
		"_ref_DungeonBoard",
		DUNGEON,
		PLAYER_INPUT, REMOVE_OBJECT, ENEMY_AI, GAME_PROGRESS, SIDEBAR_GUI,
		CREATE_OBJECT,
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
		ENEMY_AI, PLAYER_INPUT, GAME_PROGRESS, INIT_WORLD,
	],
	[
		"_ref_EndGame",
		END_GAME,
		ENEMY_AI, PLAYER_INPUT, COUNT_DOWN, GAME_PROGRESS,
	],
	[
		"_ref_CountDown",
		COUNT_DOWN,
		SIDEBAR_GUI, PLAYER_INPUT, ENEMY_AI, GAME_PROGRESS,
	],
	[
		"_ref_CreateObject",
		CREATE_OBJECT,
		INIT_WORLD, GAME_PROGRESS, ENEMY_AI, PLAYER_INPUT,
	],
	[
		"_ref_GameSetting",
		GAME_SETTING,
		INIT_WORLD, PLAYER_INPUT, SIDEBAR_GUI, RANDOM, PALETTE,
	],
	[
		"_ref_SwitchScreen",
		SWITCH_SCREEN,
		PLAYER_INPUT, HELP_INPUT, DEBUG_INPUT,
	],
	[
		"_ref_HelpVScroll",
		HELP_GUI,
		HELP_INPUT,
	],
	[
		"_ref_Palette",
		PALETTE,
		PLAYER_INPUT, SIDEBAR_GUI, CREATE_OBJECT, HELP_GUI, ENEMY_AI,
		GAME_PROGRESS, DEBUG_GUI,
	],
]


func _init().(SIGNAL_BIND, NODE_REF) -> void:
	pass
