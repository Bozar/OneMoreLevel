class_name Game_WorldTemplate
# Scripts such as Init[DungeonType].gd inherit this script.
# Override get_blueprint() and _set_dungeon_board().
# The child should also implement _init() to pass arguments.


const SPRITE_BLUEPRINT := preload("res://library/init/SpriteBlueprint.gd")

var _spr_Floor := preload("res://sprite/Floor.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")
var _spr_PC := preload("res://sprite/PC.tscn")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

var _ref_RandomNumber: Game_RandomNumber

# {0: [], 1: [], ...}
var _dungeon: Dictionary = {}
# [SpriteBlueprint, ...]
var _blueprint: Array = []


func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber

	_set_dungeon_board()
	_init_floor()


# Child scripts should implement _init() to pass arguments.
# func _init(_random: RandomNumber).(_random) -> void:
# 	pass


# Override.
func get_blueprint() -> Array:
	return _blueprint


# {0: [false, ...], 1: [false, ...], ...}
func _set_dungeon_board() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		_dungeon[i] = []
		for _j in range(_new_DungeonSize.MAX_Y):
			_dungeon[i].push_back(false)


func _occupy_position(x: int, y: int) -> void:
	_dungeon[x][y] = true


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon[x][y]


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
