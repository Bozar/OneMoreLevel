extends "res://library/init/WorldTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	for _i in range(0, 5):
		_init_building()
	_init_pc()

	return _blueprint


func _init_pc() -> void:
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			0, 0)


func _init_building() -> void:
	var x: int
	var y: int
	var neighbor: Array
	var is_occupied: bool

	while true:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X - 4)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y - 4)
		neighbor = _new_CoordCalculator.get_block(x, y, 5, 5)
		is_occupied = false

		for i in neighbor:
			if _is_occupied(i[0], i[1]):
				is_occupied = true
				break

		if is_occupied:
			continue

		for i in neighbor:
			_occupy_position(i[0], i[1])

		x += 1
		y += 1

		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				x, y)
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				x + 2, y)
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
				x + 2, y + 2)
		_add_to_blueprint(_spr_Wall,
				_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL,
			x, y + 2)

		break
