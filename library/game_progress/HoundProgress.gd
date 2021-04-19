extends "res://library/game_progress/ProgressTemplate.gd"


var _new_HoundData := preload("res://library/npc_data/HoundData.gd").new()

var _fog_source: Array = []
var _all_grounds: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	# _fog_source = [[3, 3, 1]]
	pass


func end_world(_pc_x: int, _pc_y: int) -> void:
	_add_or_remove_fog()


func remove_actor(actor: Sprite, x: int, y: int) -> void:
	if actor.is_in_group(_new_SubGroupTag.HOUND):
		_fog_source.push_back([x, y, _new_HoundData.MIN_FOG_SIZE])


func _add_or_remove_fog() -> void:
	var x: int
	var y: int
	var fog_range: int
	var remove_index: Array = []
	var neighbor: Array
	var ground: Sprite

	for i in range(_fog_source.size()):
		x = _fog_source[i][0]
		y = _fog_source[i][1]
		fog_range = _fog_source[i][2]
		if fog_range < _new_HoundData.MAX_FOG_SIZE:
			_fog_source[i][2] += 1
			neighbor = _new_CoordCalculator.get_neighbor(x, y, fog_range, true)
			for j in neighbor:
				ground = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
						j[0], j[1])
				if ground != null:
					_ref_ObjectData.add_hit_point(ground,
							_new_HoundData.FOG_DURATION)
		else:
			remove_index.push_back(i)

	for i in remove_index:
		_new_ArrayHelper.remove_by_index(_fog_source, i)

	if _all_grounds.size() == 0:
		_all_grounds = _ref_DungeonBoard.get_sprites_by_tag(
				_new_MainGroupTag.GROUND)
	for i in _all_grounds:
		if _ref_ObjectData.get_hit_point(i) > 0:
			_ref_ObjectData.subtract_hit_point(i, 1)
			_set_ground_state(i, true)
		else:
			_set_ground_state(i, false)


func _set_ground_state(ground: Sprite, is_active: bool) -> void:
	if is_active:
		_ref_ObjectData.set_state(ground, _new_ObjectStateTag.ACTIVE)
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.ACTIVE)
	else:
		_ref_ObjectData.set_state(ground, _new_ObjectStateTag.DEFAULT)
		_ref_SwitchSprite.switch_sprite(ground, _new_SpriteTypeTag.DEFAULT)
