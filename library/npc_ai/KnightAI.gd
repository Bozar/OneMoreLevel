extends "res://library/npc_ai/AITemplate.gd"


var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()


func take_action(pc: Sprite, actor: Sprite) -> void:
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var self_pos: Array = _new_ConvertCoord.vector_to_array(actor.position)
	var attack_range: int = 1

	if _new_CoordCalculator.is_inside_range(pc_pos, self_pos, attack_range):
		print("Attack")
	# else:
	# 	print("Approach")
