const RandomNumber := preload("res://scene/main/RandomNumber.gd")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()

var _ref_RandomNumber: RandomNumber

# {0: [], 1: [], ...}
var _dungeon: Dictionary = {}
# [[PackedScene, group_name, x, y], ...]
var _blueprint: Array = []


# Override.
func get_blueprint() -> Array:
	return _blueprint


func init_self(random: RandomNumber) -> void:
	_set_reference(random)
	_set_dungeon_board()


func _set_reference(random: RandomNumber) -> void:
	_ref_RandomNumber = random


# Override.
func _set_dungeon_board() -> void:
	pass
