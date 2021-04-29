extends "res://library/npc_ai/AITemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	print_text = ""

	if _pc_is_close():
		print_text = "Urist McRogueliker is scared!"


func _pc_is_close() -> bool:
	var delta_x: int = abs(_self_pos[0] - _pc_pos[0]) as int
	var delta_y: int = abs(_self_pos[1] - _pc_pos[1]) as int

	return delta_x + delta_y < 2
