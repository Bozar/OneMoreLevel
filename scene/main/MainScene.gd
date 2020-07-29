extends "res://library/RootNodeTemplate.gd"


const INIT_WORLD: String = "InitWorld"
const PLAYER_INPUT: String = "PlayerInput"
const ENEMY_AI: String = "EnemyAI"
const SCHEDULE: String = "Schedule"
const DUNGEON: String = "DungeonBoard"
const REMOVE: String = "RemoveObject"
const RANDOM: String = "RandomNumber"
const OBJECT_DATA: String = "ObjectData"
const SWITCH_SPRITE: String = "SwitchSprite"
const DANGER_ZONE: String = "DangerZone"
const END_GAME: String = "EndGame"
const COUNT_DOWN: String = "CountDown"
const GAME_PROGRESS: String = "GameProgress"
const SIDEBAR: String = "MainGUI/SidebarVBox"

const SIGNAL_BIND: Array = [
	[
		"sprite_created", "_on_InitWorld_sprite_created",
		INIT_WORLD,
		PLAYER_INPUT, ENEMY_AI, SCHEDULE, DUNGEON, OBJECT_DATA, SIDEBAR,
	],
	[
		"world_selected", "_on_InitWorld_world_selected",
		INIT_WORLD,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR, GAME_PROGRESS,
	],
	[
		"turn_started", "_on_Schedule_turn_started",
		SCHEDULE,
		PLAYER_INPUT, ENEMY_AI, SIDEBAR, COUNT_DOWN, GAME_PROGRESS,
	],
	[
		"turn_ended", "_on_Schedule_turn_ended",
		SCHEDULE,
		COUNT_DOWN,
	],
	[
		"sprite_removed", "_on_RemoveObject_sprite_removed",
		REMOVE,
		DUNGEON, SCHEDULE, OBJECT_DATA, ENEMY_AI, GAME_PROGRESS,
	],
	[
		"game_is_over", "_on_EndGame_game_is_over",
		END_GAME,
		SCHEDULE, PLAYER_INPUT, SIDEBAR,
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
		PLAYER_INPUT, REMOVE, ENEMY_AI,
	],
	[
		"_ref_Schedule",
		SCHEDULE,
		PLAYER_INPUT, ENEMY_AI, GAME_PROGRESS,
	],
	[
		"_ref_RemoveObject",
		REMOVE,
		PLAYER_INPUT,
	],
	[
		"_ref_RandomNumber",
		RANDOM,
		INIT_WORLD, PLAYER_INPUT, ENEMY_AI, SIDEBAR, GAME_PROGRESS,
	],
	[
		"_ref_ObjectData",
		OBJECT_DATA,
		ENEMY_AI, SWITCH_SPRITE, PLAYER_INPUT,
	],
	[
		"_ref_SwitchSprite",
		SWITCH_SPRITE,
		ENEMY_AI, PLAYER_INPUT,
	],
	[
		"_ref_DangerZone",
		DANGER_ZONE,
		ENEMY_AI, PLAYER_INPUT, SIDEBAR,
	],
	[
		"_ref_EndGame",
		END_GAME,
		ENEMY_AI, PLAYER_INPUT, COUNT_DOWN,
	],
	[
		"_ref_CountDown",
		COUNT_DOWN,
		SIDEBAR, PLAYER_INPUT,
	],
]


func _init().(SIGNAL_BIND, NODE_REF) -> void:
	pass
