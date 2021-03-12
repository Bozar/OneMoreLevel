extends "res://library/pc_action/PCActionTemplate.gd"


var _new_DesertData := preload("res://library/npc_data/DesertData.gd").new()

var _pc_is_number: bool = false


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func render_fov() -> void:
	var floor_sprite: Sprite

	for x in range(0, _new_DungeonSize.MAX_X):
		for y in range(0, _new_DungeonSize.MAX_Y):
			floor_sprite = _ref_DungeonBoard.get_sprite(
					_new_MainGroupTag.GROUND, x, y)
			floor_sprite.visible = not _is_building_or_trap(x, y)


func switch_sprite() -> void:
	_pc_is_number = false
	_switch_to_number(_pc_is_number)
	.switch_sprite()


func game_over(win: bool) -> void:
	.game_over(win)
	if win:
		_switch_to_number(false)
	else:
		_switch_to_number(true)
		_hide_ground_under_pc()


func wait() -> void:
	_pc_is_number = not _pc_is_number
	_switch_to_number(_pc_is_number)
	end_turn = false


func attack() -> void:
	var worm: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_target_position[0], _target_position[1])
	var is_active_spice: bool = _ref_ObjectData.verify_state(
			worm, _new_ObjectStateTag.ACTIVE)
	var pc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1])

	if (not worm.is_in_group(_new_SubGroupTag.WORM_SPICE)) \
			or _ref_ObjectData.verify_state(worm, _new_ObjectStateTag.PASSIVE):
		end_turn = false
		return

	_ref_ObjectData.set_state(worm, _new_ObjectStateTag.PASSIVE)
	_ref_SwitchSprite.switch_sprite(worm, _new_SpriteTypeTag.PASSIVE)
	_ref_CountDown.add_count(_new_DesertData.RESTORE_TURN)

	if is_active_spice:
		_ref_ObjectData.add_hit_point(pc, 1)
	if _ref_ObjectData.get_hit_point(pc) < _new_DesertData.MAX_SPICE:
		end_turn = true
	else:
		_ref_EndGame.player_win()
		end_turn = false


func interact_with_trap() -> void:
	_ref_CountDown.add_count(_new_DesertData.RESTORE_TURN)
	_remove_building_or_trap(false)


func interact_with_building() -> void:
	_remove_building_or_trap(true)


func _remove_building_or_trap(is_building: bool) -> void:
	var x: int = _target_position[0]
	var y: int = _target_position[1]

	if is_building:
		_ref_RemoveObject.remove(_new_MainGroupTag.BUILDING, x, y)
	else:
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
	end_turn = true


func _is_checkmate() -> bool:
	var x: int = _source_position[0]
	var y: int = _source_position[1]

	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)
	var max_neighbor: int = 4
	var count_neighbor: int = max_neighbor - neighbor.size()

	var actor: Sprite
	var is_head: bool
	var is_body: bool
	var is_spice: bool
	var is_passive: bool

	for i in neighbor:
		actor = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.ACTOR, i[0], i[1])
		if (actor == null):
			continue

		is_head = actor.is_in_group(_new_SubGroupTag.WORM_HEAD)
		is_body = actor.is_in_group(_new_SubGroupTag.WORM_BODY)
		is_spice = actor.is_in_group(_new_SubGroupTag.WORM_SPICE)
		is_passive = _ref_ObjectData.verify_state(
				actor, _new_ObjectStateTag.PASSIVE)

		if is_head or is_body or (is_spice and is_passive):
			count_neighbor += 1

	return count_neighbor == max_neighbor


func _is_building_or_trap(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP, x, y)


func _switch_to_number(is_number: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var type_tag: String

	if is_number:
		type_tag = _new_SpriteTypeTag.convert_digit_to_tag(
				_ref_ObjectData.get_hit_point(pc))
	elif _ref_DangerZone.is_in_danger(_source_position[0], _source_position[1]):
		type_tag = _new_SpriteTypeTag.ACTIVE
	else:
		type_tag = _new_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.switch_sprite(pc, type_tag)
