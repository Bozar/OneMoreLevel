extends "res://library/init/WorldTemplate.gd"
# Initialize a simple map for testing.


const Player := preload("res://sprite/PC.tscn")
const Dwarf := preload("res://sprite/Dwarf.tscn")
const Wall := preload("res://sprite/Wall.tscn")


func get_blueprint() -> Array:
	_init_wall()
	_init_PC()
	_init_dwarf()

	return _blueprint


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

	for x in range(min_x, max_x):
		for y in range(min_y, max_y):
			_add_to_blueprint(Wall,
					_new_MainGroupName.BUILDING, _new_SubGroupName.WALL,
					x, y)
			_occupy_position(x, y)


func _init_PC() -> void:
	_add_to_blueprint(Player,
			_new_MainGroupName.ACTOR, _new_SubGroupName.PC,
			0, 0)


func _init_dwarf() -> void:
	var dwarf: int = _ref_RandomNumber.get_int(3, 6)
	var x: int
	var y: int

	while dwarf > 0:
		x = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_X - 1)
		y = _ref_RandomNumber.get_int(1, _new_DungeonSize.MAX_Y - 1)

		if _is_occupied(x, y):
			continue
		_add_to_blueprint(Dwarf,
				_new_MainGroupName.ACTOR, _new_SubGroupName.DWARF,
				x, y)
		_occupy_position(x, y)

		dwarf -= 1


func _occupy_position(x: int, y: int) -> void:
	_dungeon[x][y] = true


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon[x][y]
