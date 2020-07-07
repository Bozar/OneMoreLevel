extends "res://library/npc_ai/AITemplate.gd"


func take_action(pc: Sprite, actor: Sprite, _node_ref: AIFuncParam) -> void:
	print_text = ""

	if _pc_is_close(pc, actor):
		print_text = "Urist McRogueliker is scared!"


func _pc_is_close(source: Sprite, target: Sprite) -> bool:
	var source_pos: Array = _new_ConvertCoord.vector_to_array(source.position)
	var target_pos: Array = _new_ConvertCoord.vector_to_array(target.position)
	var delta_x: int = abs(source_pos[0] - target_pos[0]) as int
	var delta_y: int = abs(source_pos[1] - target_pos[1]) as int

	return delta_x + delta_y < 2
