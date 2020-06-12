# Scripts such as Init[DungeonType].gd inherit this script.
# Override get_blueprint() and _set_dungeon_board().
# The child should also implement _init() to pass arguments.


const RandomNumber := preload("res://scene/main/RandomNumber.gd")
const SpriteBlueprint := preload("res://library/init/SpriteBlueprint.gd")
const Floor := preload("res://sprite/Floor.tscn")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

var _ref_RandomNumber: RandomNumber

# {0: [], 1: [], ...}
var _dungeon: Dictionary = {}
# [SpriteBlueprint, ...]
var _blueprint: Array = []


func _init(random: RandomNumber) -> void:
	_set_reference(random)
	_set_dungeon_board()
	_init_floor()


# Child scripts should implement _init() to pass arguments.
# func _init(_random: RandomNumber).(_random) -> void:
# 	pass


# Override.
func get_blueprint() -> Array:
	return _blueprint


func _set_reference(random: RandomNumber) -> void:
	_ref_RandomNumber = random


# Override.
func _set_dungeon_board() -> void:
	pass


func _add_to_blueprint(scene: PackedScene,
		main_group: String, sub_group: String, x: int, y: int) -> void:

	_blueprint.push_back(
		SpriteBlueprint.new(scene, main_group, sub_group, x, y))


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_add_to_blueprint(Floor,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.FLOOR,
					i, j)
