extends "res://library/init/WorldTemplate.gd"


var _spr_Crystal := preload("res://sprite/Crystal.tscn")
var _spr_CrystalBase := preload("res://sprite/CrystalBase.tscn")
var _spr_PCMirrorImage := preload("res://sprite/PCMirrorImage.tscn")
var _spr_Phantom := preload("res://sprite/Phantom.tscn")

var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_middle_border()
	_init_wall()
	_init_floor()
	_init_pc()
	_init_crystal()
	_init_phantom()

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
	var valid_x: Array = []
	var valid_y: Array = []
	var valid_coord: Array = []
	var block_size: int = 4
	var max_mirror: int = 5
	var index: int
	var candidate: Array = [
		[[1, 1], [1, 2]],
		[[2, 1], [2, 2]],
		[[1, 1], [2, 1]],
		[[1, 2], [2, 2]],
	]

	for i in range(1, _new_DungeonSize.CENTER_X, block_size):
		if i + block_size < _new_DungeonSize.CENTER_X:
			valid_x.push_back(i)
		else:
			break
	for j in range(1, _new_DungeonSize.MAX_Y, block_size):
		if j + block_size < _new_DungeonSize.MAX_Y:
			valid_y.push_back(j)
		else:
			break
	for i in valid_x:
		for j in valid_y:
			valid_coord.push_back([i, j])
	_new_ArrayHelper.rand_picker(valid_coord, max_mirror, _ref_RandomNumber)

	for i in valid_coord:
		index = _ref_RandomNumber.get_int(0, candidate.size())
		for j in candidate[index]:
			_create_mirror(i[0] + j[0], i[1] + j[1])
			_create_reflection(i[0] + j[0], i[1] + j[1])


func _create_reflection(x: int, y: int) -> void:
	var mirror: Array = _new_CoordCalculator.get_mirror_image(x, y,
			_new_DungeonSize.CENTER_X, y)
	_create_mirror(mirror[0], mirror[1])


func _create_mirror(x: int, y: int) -> void:
	_add_to_blueprint(_spr_Wall,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL, x, y)
	_occupy_position(x, y)


func _init_pc() -> void:
	var pc_x: int
	var pc_y: int
	var mirror: Array
	var neighbor: Array

	while true:
		pc_x = _ref_RandomNumber.get_int(0, _new_DungeonSize.CENTER_X)
		pc_y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if not _is_occupied(pc_x, pc_y):
			break

	mirror = _new_CoordCalculator.get_mirror_image(pc_x, pc_y,
			_new_DungeonSize.CENTER_X, pc_y)
	neighbor = _new_CoordCalculator.get_neighbor(pc_x, pc_y,
					_new_MirrorData.CRYSTAL_DISTANCE, true) \
			+ _new_CoordCalculator.get_neighbor(mirror[0], mirror[1],
					_new_MirrorData.CRYSTAL_DISTANCE, true)

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			pc_x, pc_y)
	_add_to_blueprint(_spr_PCMirrorImage,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC_MIRROR_IMAGE,
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


func _init_phantom() -> void:
	var count_phantom: int = 0
	var retry: int = 0
	var x: int
	var y: int

	while count_phantom < _new_MirrorData.MAX_PHANTOM:
		if retry > 999:
			break
		retry += 1

		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.CENTER_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if _is_occupied(x, y):
			continue

		_create_phantom(x, y)
		count_phantom += 1


func _create_phantom(x: int, y: int) -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			x, y, _new_MirrorData.PHANTOM_SIGHT, true)

	_add_to_blueprint(_spr_Phantom,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PHANTOM, x, y)
	for i in neighbor:
		_occupy_position(i[0], i[1])
