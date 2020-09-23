extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Crystal := preload("res://sprite/Crystal.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	pass


func remove_npc(_npc: Sprite, _x: int, _y: int) -> void:
	pass


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
	pass


func remove_trap(_trap: Sprite, _x: int, _y: int) -> void:
	print("remove trap")
