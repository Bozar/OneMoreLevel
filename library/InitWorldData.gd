const WorldTemplate := preload("res://library/init/WorldTemplate.gd")
const PCActionTemplate := preload("res://library/pc_action/PCActionTemplate.gd")
const AITemplate := preload("res://library/npc_ai/AITemplate.gd")
const ProgressTemplate \
        := preload("res://library/game_progress/ProgressTemplate.gd")

const InitDemo := preload("res://library/init/InitDemo.gd")
const InitKnight := preload("res://library/init/InitKnight.gd")

const DemoPCAction := preload("res://library/pc_action/DemoPCAction.gd")
const KnightPCAction := preload("res://library/pc_action/KnightPCAction.gd")

const DemoAI := preload("res://library/npc_ai/DemoAI.gd")
const KnightAI := preload("res://library/npc_ai/KnightAI.gd")

const DemoProgress := preload("res://library/game_progress/DemoProgress.gd")

var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _world_data: Dictionary = {
    _new_WorldTag.DEMO: [
        InitDemo, DemoPCAction, DemoAI, DemoProgress
    ],
    _new_WorldTag.KNIGHT: [
        InitKnight, KnightPCAction, KnightAI, DemoProgress
    ],
}


func get_world_template(world_tag: String) -> WorldTemplate:
    return _world_data[world_tag][0]


func get_pc_action(world_tag: String) -> PCActionTemplate:
    return _world_data[world_tag][1]


func get_enemy_ai(world_tag: String) -> AITemplate:
    return _world_data[world_tag][2]


func get_progress(world_tag: String) -> ProgressTemplate:
    return _world_data[world_tag][3]
