extends "res://library/pc_action/PCActionTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func move() -> void:
	var source_mirror: Array = _new_CoordCalculator.get_mirror_image(
			_source_position[0], _source_position[1],
			_new_DungeonSize.CENTER_X, _source_position[1])
	var target_mirror: Array = _new_CoordCalculator.get_mirror_image(
			_target_position[0], _target_position[1],
			_new_DungeonSize.CENTER_X, _target_position[1])

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.TRAP,
			source_mirror, target_mirror)

	end_turn = true
