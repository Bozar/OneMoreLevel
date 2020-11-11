extends "res://library/init/WorldTemplate.gd"


var _spr_PCBalloon := preload("res://sprite/PCBalloon.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var width: int = floor(_new_DungeonSize.MAX_X / 3.0) as int
	var middle_y: int = _new_DungeonSize.CENTER_Y
	var bottom_y: int = _new_DungeonSize.MAX_Y
	var left_top: int = 1
	var right_bottom: int = 3
	var pc_index: int
	var sprite_position: Array

	var valid_position: Array = [
		[
			left_top, width - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			width + left_top, width * 2 - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			width * 2 + left_top, width * 3 - right_bottom,
			left_top, middle_y - right_bottom
		],
		[
			left_top, width - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
		[
			width + left_top, width * 2 - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
		[
			width * 2 + left_top, width * 3 - right_bottom,
			middle_y + left_top, bottom_y - right_bottom
		],
	]

	pc_index = _ref_RandomNumber.get_int(0, valid_position.size())
	for i in range(0, valid_position.size()):
		sprite_position = _get_position(
			valid_position[i][0],
			valid_position[i][1],
			valid_position[i][2],
			valid_position[i][3]
		)
		if i == pc_index:
			_add_to_blueprint(_spr_PCBalloon,
					_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
					sprite_position[0], sprite_position[1])
		else:
			_build_wall_beacon(sprite_position[0], sprite_position[1])

	return _blueprint


func _get_position(min_x: int, max_x: int, min_y: int, max_y: int) -> Array:
	var x: int = _ref_RandomNumber.get_int(min_x, max_x)
	var y: int = _ref_RandomNumber.get_int(min_y, max_y)

	return [x, y]


func _build_wall_beacon(x: int, y: int) -> void:
	var wall: Array = [[x, y], [x + 2, y], [x + 2, y + 2], [x, y + 2]]
	var beacon: Array = [x + 1, y + 1]

	for i in wall:
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				i[0], i[1])
	_add_to_blueprint(_spr_Treasure,
			_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE,
			beacon[0], beacon[1])
