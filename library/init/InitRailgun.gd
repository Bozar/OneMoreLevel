extends "res://library/init/WorldTemplate.gd"


var _newRailgunData := preload("res://library/npc_data/RailgunData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_pc()

	return _blueprint


func _init_wall() -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			_add_to_blueprint(_spr_Wall,
					_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
					x, y)
			_occupy_position(x, y)


func _init_pc() -> void:
	var x: int
	var y: int
	var neighbor: Array

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)

		if not _is_occupied(x, y):
			_add_to_blueprint(_spr_PC,
					_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
					x, y)

			neighbor = _new_CoordCalculator.get_neighbor(x, y,
					_newRailgunData.NPC_SIGHT, true)
			for i in neighbor:
				_occupy_position(i[0], i[1])
			break
