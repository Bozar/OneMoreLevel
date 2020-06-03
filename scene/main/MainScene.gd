extends "res://library/RootNodeTemplate.gd"


const INIT_WORLD: String = "InitWorld"
const PC_INPUT: String = "PCInput"
const PC_MOVE: String = "PCMove"
const PC_ATTACK: String = "PCMove/PCAttack"
const ENEMY_AI: String = "EnemyAI"
const SCHEDULE: String = "Schedule"
const DUNGEON: String = "DungeonBoard"
const REMOVE: String = "RemoveObject"
const RANDOM: String = "RandomNumber"
const SIDEBAR: String = "MainGUI/MainHBox/SidebarVBox"
const MODELINE: String = "MainGUI/MainHBox/Modeline"

const SIGNAL_BIND: Array = [
	[
		"sprite_created", "_on_InitWorld_sprite_created",
		INIT_WORLD,
		PC_INPUT, PC_MOVE, ENEMY_AI, SCHEDULE, DUNGEON,
	],
	[
		"world_selected", "_on_InitWorld_world_selected",
		INIT_WORLD,
		PC_INPUT, ENEMY_AI,
	],
	[
		"turn_started", "_on_Schedule_turn_started",
		SCHEDULE,
		PC_INPUT, PC_MOVE, ENEMY_AI, SIDEBAR,
	],
	[
		"turn_ended", "_on_Schedule_turn_ended",
		SCHEDULE,
		MODELINE,
	],
	[
		"sprite_removed", "_on_RemoveObject_sprite_removed",
		REMOVE,
		DUNGEON, SCHEDULE,
	],
	[
		"enemy_warned", "_on_EnemyAI_enemy_warned",
		ENEMY_AI,
		MODELINE,
	],
	[
		"pc_moved", "_on_PCMove_pc_moved",
		PC_MOVE,
		MODELINE,
	],
	[
		"pc_attacked", "_on_PCAttack_pc_attacked",
		PC_ATTACK,
		MODELINE,
	],
]

const NODE_REF: Array = [
	[
		"_ref_DungeonBoard",
		DUNGEON,
		PC_INPUT, PC_MOVE, PC_ATTACK, REMOVE,
	],
	[
		"_ref_Schedule",
		SCHEDULE,
		PC_INPUT, PC_MOVE, ENEMY_AI, PC_ATTACK,
	],
	[
		"_ref_RemoveObject",
		REMOVE,
		PC_ATTACK,
	],
	[
		"_ref_RandomNumber",
		RANDOM,
		INIT_WORLD,
	],
]


func _init().(SIGNAL_BIND, NODE_REF) -> void:
	pass
