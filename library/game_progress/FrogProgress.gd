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
			_new_SubGroupTag.SWAMP)
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			pc_x, pc_y, _new_FrogData.SIGHT, true)
	var frog_pos: Array = []

	var max_frog: int = _new_FrogData.MAX_FROG
	var frog_sprite: PackedScene = _spr_Frog
	var frog_tag: String = _new_SubGroupTag.FROG

	if is_princess:
		max_frog = 1
		frog_sprite = _spr_FrogPrincess
		frog_tag = _new_SubGroupTag.FROG_PRINCESS

	_new_ArrayHelper.filter_element(swamp, self, "_filter_spawn_position",
			[neighbor])
	_new_ArrayHelper.random_picker(swamp, max_frog, _ref_RandomNumber)

	for i in swamp:
		frog_pos = _new_ConvertCoord.vector_to_array(i.position)
		_ref_CreateObject.create(frog_sprite,
				_new_MainGroupTag.ACTOR, frog_tag, frog_pos[0], frog_pos[1])


func _filter_spawn_position(source: Array, index: int, opt_arg: Array) -> bool:
	var pos: Array = _new_ConvertCoord.vector_to_array(source[index].position)
	var neighbor: Array = opt_arg[0]

	return not pos in neighbor


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
