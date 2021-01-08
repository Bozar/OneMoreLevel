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
var _wave_counter: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func renew_world(pc_x: int, pc_y: int) -> void:
	if _wave_counter == 0:
		_create_frog(pc_x, pc_y, false)
		_wave_counter += 1


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	print("remove actor")


func _create_frog(pc_x: int, pc_y: int, is_princess: bool) -> void:
	var swamp: Array = _ref_DungeonBoard.get_sprites_by_tag(
			_new_SubGroupTag.FLOOR)
	var counter: int = 0
	var tmp_index: int
	var tmp_pos: Array
	var frog_pos: Array = []

	var max_frog: int = _new_FrogData.MAX_FROG
	var frog_sight: int = _new_FrogData.SIGHT
	var frog_sprite: PackedScene = _spr_Frog
	var frog_tag: String = _new_SubGroupTag.FROG

	if is_princess:
		max_frog = 1
		frog_sight = _new_FrogData.PRINCESS_SIGHT
		frog_sprite = _spr_FrogPrincess
		frog_tag = _new_SubGroupTag.FROG_PRINCESS

	while counter < max_frog:
		tmp_index = _ref_RandomNumber.get_int(counter, swamp.size())
		tmp_pos = _new_ConvertCoord.vector_to_array(swamp[tmp_index].position)
		if _new_CoordCalculator.is_inside_range(
				tmp_pos[0], tmp_pos[1], pc_x, pc_y, frog_sight):
			continue

		_new_ArrayHelper.swap_element(swamp, counter, tmp_index)
		frog_pos.push_back(tmp_pos)
		counter += 1

	for i in frog_pos:
		_ref_CreateObject.create(frog_sprite,
				_new_MainGroupTag.ACTOR, frog_tag, i[0], i[1])


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
				_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR, x, y)
