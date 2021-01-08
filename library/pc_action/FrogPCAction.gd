extends "res://library/pc_action/PCActionTemplate.gd"


var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()

var _pass_next_turn: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func allow_input() -> bool:
	if _pass_next_turn:
		_pass_next_turn = false
		return false
	return true


func is_npc() -> bool:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var reach_x: int = (_target_position[0] - _source_position[0]) * 2 \
			+ _source_position[0]
	var reach_y: int = (_target_position[1] - _source_position[1]) * 2 \
			+ _source_position[1]

	if _ref_ObjectData.verify_state(pc, _new_ObjectStateTag.ACTIVE):
		return false
	elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1]):
		return true
	elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
			reach_x, reach_y):
		_target_position[0] = reach_x
		_target_position[1] = reach_y
		return true
	return false


func is_building() -> bool:
	return false


func is_trap() -> bool:
	return false


func move() -> void:
	if not _is_on_land(_source_position[0], _source_position[1]):
		_pass_next_turn = true
	.move()


func attack() -> void:
	_ref_CountDown.add_count(_new_FrogData.RESTORE_TURN)
	.attack()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var x: int = pc_pos[0]
	var y: int = pc_pos[1]

	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.ACTIVE)
	elif not _is_on_land(x, y):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)


func _is_on_land(x: int, y: int) -> bool:
	var ground_sprite: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.GROUND, x, y)

	return ground_sprite.is_in_group(_new_SubGroupTag.LAND)
