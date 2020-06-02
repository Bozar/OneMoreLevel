extends "res://library/pc_action/PCActionTemplate.gd"


func is_ground(_x: int, _y: int) -> bool:
	return false


func is_npc(_x: int, _y: int) -> bool:
	return false


func move() -> void:
	print("move")


func attack() -> void:
	pass


func wait() -> void:
	print("wait")
