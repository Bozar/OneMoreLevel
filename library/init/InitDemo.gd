# Initialize a simple map for testing.

const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Wall := preload("res://sprite/Wall.tscn")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()

var _ref_RandomNumber: RandomNumber

var _dungeon: Dictionary = {}
# [[PackedScene, group_name, x, y], ...]
var _blueprint: Array = []


func get_blueprint() -> Array:
	_init_wall()
	_init_PC()
	_init_dwarf()

	return _blueprint


func init_self(random: RandomNumber) -> void:
	_set_reference(random)
	_set_dungeon_board()


func _set_reference(random: RandomNumber) -> void:
	_ref_RandomNumber = random


# {0: [false, ...], 1: [false, ...], ...}
func _set_dungeon_board() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		_dungeon[i] = []
		for _j in range(_new_DungeonSize.MAX_Y):
			_dungeon[i].push_back(false)


func _init_wall() -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for i in range(min_x, max_x):
		for j in range(min_y, max_y):
			_blueprint.push_back([Wall, _new_GroupName.WALL, i, j])
			_occupy_position(i, j)


func _init_PC() -> void:
	_blueprint.push_back([Player, _new_GroupName.PC, 0, 0])


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X - 1)
		y = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_Y - 1)

		if _is_occupied(x, y):
			continue
		_blueprint.push_back([Dwarf, _new_GroupName.DWARF, x, y])
		_occupy_position(x, y)

		dwarf -= 1


func _occupy_position(x: int, y: int) -> void:
	_dungeon[x][y] = true


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon[x][y]
