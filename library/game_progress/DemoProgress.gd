extends "res://library/game_progress/ProgressTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(_pc_x: int, _pc_y: int) -> void:
	print("renew world")


func remove_npc(_npc: Sprite, _x: int, _y: int) -> void:
	print("remove npc")


func remove_building(_building: Sprite, _x: int, _y: int) -> void:
	print("remove building")
