class_name Game_ProgressTemplate


var _ref_RandomNumber: Game_RandomNumber
var _ref_Schedule: Game_Schedule

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()


func _init(parent_node: Node2D) -> void:
    _ref_RandomNumber = parent_node._ref_RandomNumber
    _ref_Schedule = parent_node._ref_Schedule


func renew_world() -> void:
    pass


func remove_npc(_npc: Sprite, _x: int, _y: int) -> void:
    pass


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
    pass
