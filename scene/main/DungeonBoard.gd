extends Node2D


var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

# <main_group: String, <column: int, [sprite]>>
var _sprite_dict: Dictionary

var _valid_main_groups: Array = [
	_new_MainGroupTag.ACTOR, _new_MainGroupTag.BUILDING,
]

var _sub_group_to_sprite: Dictionary = {
	_new_SubGroupTag.ARROW_LEFT: null,
	_new_SubGroupTag.ARROW_TOP: null,
}


func _ready() -> void:
	_init_dict()


func has_sprite(main_group: String, x: int, y: int) -> bool:
	return get_sprite(main_group, x, y) != null


func get_sprite(main_group: String, x: int, y: int) -> Sprite:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return null
	return _sprite_dict[main_group][x][y]


func move_sprite(main_group: String, source: Array, target: Array) -> void:
	var sprite: Sprite = get_sprite(main_group, source[0], source[1])

	if sprite == null:
		return

	_sprite_dict[main_group][source[0]][source[1]] = null
	_sprite_dict[main_group][target[0]][target[1]] = sprite
	sprite.position = _new_ConvertCoord.index_to_vector(target[0], target[1])

	# Move arrow indicators when PC moves.
	if sprite.is_in_group(_new_SubGroupTag.PC):
		_sub_group_to_sprite[_new_SubGroupTag.ARROW_LEFT] \
				.position.y = sprite.position.y
		_sub_group_to_sprite[_new_SubGroupTag.ARROW_TOP] \
				.position.x = sprite.position.x


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	var pos: Array
	var group: String

	# Save references to arrow indicators.
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		for sg in _sub_group_to_sprite.keys():
			if new_sprite.is_in_group(sg):
				_sub_group_to_sprite[sg] = new_sprite
		return

	# Save references to dungeon sprites.
	for mg in _valid_main_groups:
		if new_sprite.is_in_group(mg):
			group = mg
	if group == "":
		return
	pos = _new_ConvertCoord.vector_to_array(new_sprite.position)
	_sprite_dict[group][pos[0]][pos[1]] = new_sprite


func _on_RemoveObject_sprite_removed(_sprite: Sprite, main_group: String,
		x: int, y: int) -> void:
	_sprite_dict[main_group][x][y] = null


func _init_dict() -> void:
	for mg in _valid_main_groups:
		_sprite_dict[mg] = {}
		for x in range(_new_DungeonSize.MAX_X):
			_sprite_dict[mg][x] = []
			_sprite_dict[mg][x].resize(_new_DungeonSize.MAX_Y)
