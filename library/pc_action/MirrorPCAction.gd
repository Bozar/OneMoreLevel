extends "res://library/pc_action/PCActionTemplate.gd"


var _pc_hit_target: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func is_npc() -> bool:
	return _target_is_occupied(_new_MainGroupTag.ACTOR)


func is_trap() -> bool:
	return _target_is_occupied(_new_MainGroupTag.TRAP)


func move() -> void:
	var source_mirror: Array = _get_mirror(
			_source_position[0], _source_position[1])
	var target_mirror: Array = _get_mirror(
			_target_position[0], _target_position[1])
	var crystal: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.TRAP, _source_position[0], _source_position[1])

	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.TRAP,
			source_mirror, target_mirror)

	if crystal != null:
		crystal.visible = true

	end_turn = true


func attack() -> void:
	var mirror: Array

	if _pc_hit_target:
		# TODO: More things shall happen when PC hits a phantom.
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
				_target_position[0], _target_position[1])
	else:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, mirror[0], mirror[1])
	end_turn = true


func interact_with_trap() -> void:
	var crystal: Sprite
	var mirror: Array

	if _pc_hit_target:
		crystal = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.TRAP,
				_target_position[0], _target_position[1])
		crystal.visible = false
	else:
		mirror = _get_mirror(_target_position[0], _target_position[1])
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, mirror[0], mirror[1])
	move()


func _get_mirror(x: int, y: int) -> Array:
	return _new_CoordCalculator.get_mirror_image(
			x, y, _new_DungeonSize.CENTER_X, y)


func _target_is_occupied(main_group_tag: String) -> bool:
	var mirror: Array = _get_mirror(_target_position[0], _target_position[1])

	if _ref_DungeonBoard.has_sprite(main_group_tag,
			_target_position[0], _target_position[1]):
		_pc_hit_target = true
		return true
	elif _ref_DungeonBoard.has_sprite(main_group_tag,
			mirror[0], mirror[1]):
		_pc_hit_target = false
		return true
	return false
