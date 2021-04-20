extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Hound := preload("res://sprite/Hound.tscn")
var _spr_HoundBoss := preload("res://sprite/HoundBoss.tscn")

var _new_HoundData := preload("res://library/npc_data/HoundData.gd").new()

var _fog_source: Array = []
var _all_grounds: Array = []
var _current_hound: int = _new_HoundData.MAX_HOUND
var _minion_trigger: bool = false
var _boss_trigger: bool = true


func _init(parent_node: Node2D).(parent_node) -> void:
	# _fog_source = [[3, 3, 0]]
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	_respawn_boss(pc_x, pc_y)
	_respawn_minion(pc_x, pc_y)
	_add_or_remove_fog()


func remove_actor(actor: Sprite, x: int, y: int) -> void:
	if actor.is_in_group(_new_SubGroupTag.HOUND):
		_fog_source.push_back([x, y, _new_HoundData.MIN_FOG_SIZE])
		_current_hound -= 1
		if _current_hound <= _new_HoundData.START_RESPAWN:
			_minion_trigger = true
	elif actor.is_in_group(_new_SubGroupTag.HOUND_BOSS):
		_boss_trigger = true


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


func _respawn_minion(pc_x: int, pc_y: int) -> void:
	if not _minion_trigger:
		return

	_current_hound += 1
	if _current_hound == _new_HoundData.MAX_HOUND:
		_minion_trigger = false
	_respawn_actor(pc_x, pc_y,
			_new_HoundData.MIN_MINION_DISTANCE,
			_new_HoundData.MAX_MINION_DISTANCE,
			_spr_Hound, _new_SubGroupTag.HOUND)


func _respawn_boss(pc_x: int, pc_y: int) -> void:
	if (not _boss_trigger) or (_current_hound < _new_HoundData.MAX_HOUND):
		return

	_boss_trigger = false
	_respawn_actor(pc_x, pc_y,
			_new_HoundData.MIN_BOSS_DISTANCE,
			_new_HoundData.MAX_BOSS_DISTANCE,
			_spr_HoundBoss, _new_SubGroupTag.HOUND_BOSS)


func _respawn_actor(pc_x: int, pc_y: int, min_distance: int, max_distance: int,
		new_sprite: PackedScene, sub_tag: String) -> void:
	var x: int
	var y: int
	var neighbor: Array
	var next_loop: bool

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		next_loop = false
		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
			next_loop = true
		elif _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y):
			next_loop = true
		elif _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				min_distance):
			next_loop = true
		elif not _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				max_distance):
			next_loop = true
		else:
			neighbor = _new_CoordCalculator.get_neighbor(x, y,
					_new_HoundData.MIN_HOUND_GAP)
			for i in neighbor:
				if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
						i[0], i[1]):
					next_loop = true
					break
		if not next_loop:
			break
	_ref_CreateObject.create(new_sprite, _new_MainGroupTag.ACTOR, sub_tag, x, y)
