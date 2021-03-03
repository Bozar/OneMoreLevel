class_name Game_WorldTemplate
# Scripts such as Init[DungeonType].gd inherit this script.
# Override get_blueprint() and _init_dungeon_board().
# The child should also implement _init() to pass arguments.


const SPRITE_BLUEPRINT := preload("res://library/init/SpriteBlueprint.gd")

var _spr_Floor := preload("res://sprite/Floor.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")
var _spr_PC := preload("res://sprite/PC.tscn")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _ref_RandomNumber: Game_RandomNumber
var _ref_DangerZone: Game_DangerZone

# {0: [false, ...], 1: [false, ...], ...}
var _dungeon_with_bool: Dictionary = {}
# {0: [0, ...], 1: [0, ...], ...}
var _dungeon_with_int: Dictionary = {}
# [SpriteBlueprint, ...]
var _blueprint: Array = []


func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_DangerZone = parent_node._ref_DangerZone

	_init_dungeon_board()
	_init_floor()


# Child scripts should implement _init() to pass arguments.
# func _init(_random: RandomNumber).(_random) -> void:
# 	pass


# Override.
func get_blueprint() -> Array:
	return _blueprint


# Use `_occupy` functions by default. If use `_terrain_marker` functions,
# overwrite `_init_dungeon_board()` in a child script.
func _init_dungeon_board() -> void:
	_fill_dungeon_board(true)


func _fill_dungeon_board(with_bool: bool) -> void:
	var dungeon: Dictionary = _dungeon_with_bool if with_bool \
			else _dungeon_with_int

	for i in range(_new_DungeonSize.MAX_X):
		dungeon[i] = []
		dungeon[i].resize(_new_DungeonSize.MAX_Y)
		for j in range(_new_DungeonSize.MAX_Y):
			if with_bool:
				dungeon[i][j] = false
			else:
				dungeon[i][j] = 0


func _occupy_position(x: int, y: int) -> void:
	_dungeon_with_bool[x][y] = true


func _reverse_occupy(x: int, y: int) -> void:
	_dungeon_with_bool[x][y] = not _dungeon_with_bool[x][y]


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon_with_bool[x][y]


func _set_terrain_marker(x: int, y: int, marker: int) -> void:
	_dungeon_with_int[x][y] = marker


func _get_terrain_marker(x: int, y: int) -> int:
	return _dungeon_with_int[x][y]


func _add_to_blueprint(scene: PackedScene,
		main_group: String, sub_group: String, x: int, y: int) -> void:
	_blueprint.push_back(SPRITE_BLUEPRINT.new(
			scene, main_group, sub_group, x, y))


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_add_to_blueprint(_spr_Floor,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR,
					i, j)


func _init_pc() -> void:
	var x: int
	var y: int
	var neighbor: Array
	var min_range: int = 5

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

		if _is_occupied(x, y):
			continue
		break

	neighbor = _new_CoordCalculator.get_neighbor(x, y, min_range, true)
	for i in neighbor:
		_occupy_position(i[0], i[1])

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			x, y)
