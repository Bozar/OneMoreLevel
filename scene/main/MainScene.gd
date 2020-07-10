extends "res://library/RootNodeTemplate.gd"


const INIT_WORLD: String = "InitWorld"
const PC_INPUT: String = "PCInput"
const ENEMY_AI: String = "EnemyAI"
const SCHEDULE: String = "Schedule"
const DUNGEON: String = "DungeonBoard"
const REMOVE: String = "RemoveObject"
const RANDOM: String = "RandomNumber"
const OBJECT_DATA: String = "ObjectData"
const SWITCH_SPRITE: String = "SwitchSprite"
const SIDEBAR: String = "MainGUI/SidebarVBox"

const SIGNAL_BIND: Array = [
	[
		"sprite_created", "_on_InitWorld_sprite_created",
		INIT_WORLD,
		PC_INPUT, ENEMY_AI, SCHEDULE, DUNGEON, OBJECT_DATA,
	],
	[
		"world_selected", "_on_InitWorld_world_selected",
		INIT_WORLD,
		PC_INPUT, ENEMY_AI,
	],
	[
		"turn_started", "_on_Schedule_turn_started",
		SCHEDULE,
		PC_INPUT, ENEMY_AI, SIDEBAR,
	],
	# [
	# 	"turn_ended", "_on_Schedule_turn_ended",
	# 	SCHEDULE,
	# 	MODELINE,
	# ],
	[
		"sprite_removed", "_on_RemoveObject_sprite_removed",
		REMOVE,
		DUNGEON, SCHEDULE, OBJECT_DATA,
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
		PC_INPUT, REMOVE, ENEMY_AI,
	],
	[
		"_ref_Schedule",
		SCHEDULE,
		PC_INPUT, ENEMY_AI,
	],
	[
		"_ref_RemoveObject",
		REMOVE,
		PC_INPUT,
	],
	[
		"_ref_RandomNumber",
		RANDOM,
		INIT_WORLD,
	],
	[
		"_ref_ObjectData",
		OBJECT_DATA,
		ENEMY_AI, SWITCH_SPRITE,
	],
	[
		"_ref_SwitchSprite",
		SWITCH_SPRITE,
		ENEMY_AI,
	],
]


func _init().(SIGNAL_BIND, NODE_REF) -> void:
	pass
