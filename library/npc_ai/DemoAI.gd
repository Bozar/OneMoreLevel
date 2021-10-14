extends Game_AITemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	print_text = ""

	if _pc_is_close():
		print_text = "Urist McRogueliker is scared!"


func _pc_is_close() -> bool:
	var delta_x: int = abs(_self_pos.x - _pc_pos.x) as int
	var delta_y: int = abs(_self_pos.y - _pc_pos.y) as int

	return delta_x + delta_y < 2
