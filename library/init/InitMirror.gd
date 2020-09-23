extends "res://library/init/WorldTemplate.gd"


var _spr_Crystal := preload("res://sprite/Crystal.tscn")
var _spr_CrystalBase := preload("res://sprite/CrystalBase.tscn")
var _spr_PCMirrorImage := preload("res://sprite/PCMirrorImage.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()

var _pc_x: int
var _pc_y: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_middle_border()
	_init_wall()
	_init_pc()
	_init_crystal()

	return _blueprint


func _init_middle_border() -> void:
	var crystal_base: Array = [
		_new_MirrorData.CENTER_Y_1,
		_new_MirrorData.CENTER_Y_2,
		_new_MirrorData.CENTER_Y_3,
		_new_MirrorData.CENTER_Y_4,
		_new_MirrorData.CENTER_Y_5,
	]
	var new_sprite: PackedScene
	var sub_group_tag: String

	for i in range(_new_DungeonSize.MAX_Y):
		if i in crystal_base:
			new_sprite = _spr_CrystalBase
			sub_group_tag = _new_SubGroupTag.CRYSTAL_BASE
		else:
			new_sprite = _spr_Wall
			sub_group_tag = _new_SubGroupTag.WALL

		_add_to_blueprint(new_sprite,
				_new_MainGroupTag.BUILDING, sub_group_tag,
				_new_DungeonSize.CENTER_X, i)
		_occupy_position(_new_DungeonSize.CENTER_X, i)


func _init_wall() -> void:
	var count_wall: int = 0
	var max_wall: int = 5
	var direction: int
	var retry: int = 0

	while count_wall < max_wall:
		if retry > 999:
			break
		retry += 1

		direction = _ref_RandomNumber.get_int(0, 2)
		if direction == 0:
			if _try_create_horizonal_wall():
				count_wall += 1
		elif direction == 1:
			if _try_create_vertical_wall():
				count_wall += 1

	_create_reflection()


func _try_create_horizonal_wall() -> bool:
	var x: int = _ref_RandomNumber.get_int(2, _new_DungeonSize.CENTER_X - 3)
	var y: int = _ref_RandomNumber.get_int(2, _new_DungeonSize.MAX_Y - 2)
	var neighbor: Array = _new_CoordCalculator.get_block(x - 2, y - 2, 6, 5)
	var wall: Array = [[x, y], [x + 1, y]]

	return _try_create_wall(neighbor, wall)


func _try_create_vertical_wall() -> bool:
	var x: int = _ref_RandomNumber.get_int(2, _new_DungeonSize.CENTER_X - 2)
	var y: int = _ref_RandomNumber.get_int(2, _new_DungeonSize.MAX_Y - 3)
	var neighbor: Array = _new_CoordCalculator.get_block(x - 2, y - 2, 5, 6)
	var wall: Array = [[x, y], [x, y + 1]]

	return _try_create_wall(neighbor, wall)


func _try_create_wall(neighbor: Array, wall: Array) -> bool:
	for i in neighbor:
		if _is_occupied(i[0], i[1]):
			return false
	for i in wall:
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				i[0], i[1])
		_occupy_position(i[0], i[1])
	return true


func _create_reflection() -> void:
	var mirror: Array

	for i in range(0, _new_DungeonSize.CENTER_X):
		for j in range(0, _new_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				mirror = _new_CoordCalculator.get_mirror_image(
						i, j, _new_DungeonSize.CENTER_X, j)
				_add_to_blueprint(_spr_Wall,
						_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
						mirror[0], mirror[1])
				_occupy_position(mirror[0], mirror[1])


func _init_pc() -> void:
	while true:
		_pc_x = _ref_RandomNumber.get_int(0, _new_DungeonSize.CENTER_X)
		_pc_y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if not _is_occupied(_pc_x, _pc_y):
			break

	var mirror: Array = _new_CoordCalculator.get_mirror_image(
			_pc_x, _pc_y, _new_DungeonSize.CENTER_X, _pc_y)
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			_pc_x, _pc_y, _new_MirrorData.CRYSTAL_DISTANCE, true)
	neighbor.push_back([mirror[0], mirror[1]])

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			_pc_x, _pc_y)
	_add_to_blueprint(_spr_PCMirrorImage,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.PC_MIRROR_IMAGE,
			mirror[0], mirror[1])

	for i in neighbor:
		_occupy_position(i[0], i[1])


func _init_crystal() -> void:
	var x: int
	var y: int

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if _is_occupied(x, y):
			continue
		break

	_add_to_blueprint(_spr_Crystal,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.CRYSTAL,
			x, y)
	_occupy_position(x, y)
	_ref_DangerZone.set_danger_zone(x, y, true)
