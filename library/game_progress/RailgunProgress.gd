extends "res://library/game_progress/ProgressTemplate.gd"


var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	pass


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	pass
