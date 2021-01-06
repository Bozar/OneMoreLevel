extends "res://library/pc_action/PCActionTemplate.gd"


var _counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func allow_input() -> bool:
	_counter += 1
	if _counter == 3:
		return false
	return true


func pass_turn() -> void:
	print("pass this turn")
