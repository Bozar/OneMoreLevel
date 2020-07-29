extends "res://library/game_progress/ProgressTemplate.gd"


var _new_KnightData := preload("res://library/npc_data/KnightData.gd")

var _dead_captain: int = 0
var _spawn_captain: bool = false
var _spawn_boss: bool = false


func _init(parent_node: Node2D).(parent_node) -> void:
    pass


func renew_world() -> void:
    pass


func remove_npc(npc: Sprite, _x: int, _y: int) -> void:
    if npc.is_in_group(_new_SubGroupTag.KNIGHT_CAPTAIN):
        _dead_captain += 1

        if _dead_captain < _new_KnightData.MAX_CAPTAIN:
            _spawn_captain = true
            _spawn_boss = false
        else:
            _spawn_captain = false
            _spawn_boss = true


# func _spawn_npc(scene: PackedScene, sub_tag: String) -> void:
    # var x: int = 0
    # var y: int = 0

    # _ref_InitWorld.create_sprite(scene, _new_MainGroupTag.ACTOR, sub_tag, x, y)
