extends "res://library/pc_action/PCActionTemplate.gd"


var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func move() -> void:
	_switch_color(_source_position, true)

	end_turn = _try_move()
	if not end_turn:
		return

	_switch_color(_target_position, false)


func _try_move() -> bool:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)

	return true


func _switch_color(position: Array, is_default_color: bool) -> void:
	var sprite_color: String
	var neighbor: Array
	var ground_sprite: Sprite

	if is_default_color:
		sprite_color = _new_Palette.get_default_color(_new_MainGroupTag.GROUND)
	else:
		sprite_color = _new_Palette.SHADOW

	neighbor = _new_CoordCalculator.get_neighbor(
			position[0], position[1], _new_StyxData.PC_SIGHT)
	for i in neighbor:
		ground_sprite = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.GROUND, i[0], i[1])
		if ground_sprite == null:
			continue
		ground_sprite.modulate = sprite_color
