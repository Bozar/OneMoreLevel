extends "res://library/game_progress/ProgressTemplate.gd"


var _spr_Frog := preload("res://sprite/Frog.tscn")
var _spr_FrogPrincess := preload("res://sprite/FrogPrincess.tscn")
var _spr_Floor := preload("res://sprite/Floor.tscn")

var _new_FrogData := preload("res://library/npc_data/FrogData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

# wave counter:
# 0: 8 frogs
# 1: princess, submerge land
# 2: 8 frogs
# 3: princess, 4 frogs, submerge land
# -3: princess dies before other frogs
# 4: princess
var _start_next_wave: bool = true
var _wave_counter: int = 0
var _kill_counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(pc_x: int, pc_y: int) -> void:
	if _start_next_wave:
		_start_next_wave = false

		if _wave_counter == 0:
			_create_frog(pc_x, pc_y)


func end_world(pc_x: int, pc_y: int) -> void:
	if _start_next_wave:
		_start_next_wave = false

		if _wave_counter == 1:
			_submerge_land()
			_remove_frog()
			_create_princess(pc_x, pc_y)
		elif _wave_counter == 2:
			_create_frog(pc_x, pc_y)
		elif _wave_counter == 3:
			_submerge_land()
			_create_princess(pc_x, pc_y)
		elif _wave_counter == -3:
			_create_princess(pc_x, pc_y)
			_wave_counter = 3


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if actor.is_in_group(_new_SubGroupTag.FROG):
		_kill_counter += 1
		if _kill_counter == _new_FrogData.HALF_FROG:
			_kill_counter = 0
			if (_wave_counter == 0) or (_wave_counter == 2) \
					or (_wave_counter == 3):
				_wave_counter += 1
				_start_next_wave = true
	elif actor.is_in_group(_new_SubGroupTag.FROG_PRINCESS):
		if _wave_counter == 1:
			_wave_counter += 1
			_start_next_wave = true
		elif _wave_counter == 3:
			_wave_counter = -3
			_start_next_wave = true
		elif _wave_counter == 4:
			_ref_EndGame.player_win()


func _create_frog(pc_x: int, pc_y: int) -> void:
	var swamp: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.SWAMP)
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			pc_x, pc_y, _new_FrogData.SIGHT, true)
	var frog_pos: Array = []

	_new_ArrayHelper.filter_element(swamp, self, "_filter_create_frog",
			[neighbor])
	_new_ArrayHelper.random_picker(swamp, _new_FrogData.MAX_FROG,
			_ref_RandomNumber)

	for i in swamp:
		frog_pos = _new_ConvertCoord.vector_to_array(i.position)
		_ref_CreateObject.create(_spr_Frog,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.FROG,
				frog_pos[0], frog_pos[1])


func _create_princess(pc_x: int, pc_y: int) -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			pc_x, pc_y, _new_FrogData.PRINCESS_SIGHT, true)

	_new_ArrayHelper.filter_element(neighbor, self, "_filter_create_princess",
			[pc_x, pc_y])
	_new_ArrayHelper.duplicate_element(neighbor, self, "_dup_create_princess",
			[])
	_new_ArrayHelper.random_picker(neighbor, 1, _ref_RandomNumber)

	_ref_CreateObject.create(_spr_FrogPrincess,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.FROG_PRINCESS,
				neighbor[0][0], neighbor[0][1])


func _submerge_land() -> void:
	var land_sprite: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.LAND)
	var land_pos: Array
	var x: int
	var y: int

	_new_ArrayHelper.random_picker(land_sprite, _new_FrogData.SUBMERGE_LAND,
			_ref_RandomNumber)

	for i in land_sprite:
		land_pos = _new_ConvertCoord.vector_to_array(i.position)
		x = land_pos[0]
		y = land_pos[1]

		_ref_RemoveObject.remove(_new_MainGroupTag.GROUND, x, y)
		_ref_CreateObject.create(_spr_Floor,
				_new_MainGroupTag.GROUND, _new_SubGroupTag.SWAMP, x, y)


func _remove_frog() -> void:
	var frog: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.FROG)
	var pos: Array

	for i in frog:
		pos = _new_ConvertCoord.vector_to_array(i.position)
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR, pos[0], pos[1])


func _filter_create_frog(source: Array, index: int, opt_arg: Array) -> bool:
	var pos: Array = _new_ConvertCoord.vector_to_array(source[index].position)
	var neighbor: Array = opt_arg[0]

	return not pos in neighbor


func _filter_create_princess(source: Array, index: int, opt_arg: Array) -> bool:
	var sor_x: int = source[index][0]
	var sor_y: int = source[index][1]
	var pc_x: int = opt_arg[0]
	var pc_y: int = opt_arg[1]

	if _new_CoordCalculator.is_inside_range(sor_x, sor_y, pc_x, pc_y,
			_new_FrogData.ATTACK_RANGE) \
					or _ref_DungeonBoard.has_sprite(
							_new_MainGroupTag.ACTOR, sor_x, sor_y):
		return false
	return true


func _dup_create_princess(source: Array, index: int, _opt_arg: Array) -> int:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(
			_new_MainGroupTag.GROUND, _new_SubGroupTag.SWAMP,
			source[index][0], source[index][1]):
		return 2
	return 1
