extends "res://library/init/WorldTemplate.gd"
# Initialize a simple map for testing.


var _spr_Dwarf := preload("res://sprite/Dwarf.tscn")

var _dungeon: Dictionary = {}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_floor()
	_init_pc()
	_init_dwarf()

	return _blueprint


func _init_wall() -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			_occupy_position(x, y)
			_add_to_blueprint(_spr_Wall,
					_new_MainGroupTag.BUILDING, _new_SubGroupTag.WALL, x, y)


func _init_pc() -> void:
	var x: int = 0
	var y: int = 0

	_occupy_position(x, y)
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, x, y)


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_X)
		y = _ref_RandomNumber.get_int(0, _new_DungeonSize.MAX_Y)
		if _is_occupied(x, y):
			continue

		_occupy_position(x, y)
		_add_to_blueprint(_spr_Dwarf,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.DWARF, x, y)
		dwarf -= 1
