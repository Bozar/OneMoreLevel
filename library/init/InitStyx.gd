extends Game_WorldTemplate


const HARBOR_MARKER := OCCUPIED_MARKER + 1
const PC_X := 1
const PC_Y := Game_DungeonSize.MAX_Y - 2

var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")
var _spr_Arrow := preload("res://sprite/Arrow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_lighthouse()
	_init_harbor()
	_init_river()
	_init_pc(0, PC_X, PC_Y)

	return _blueprint


func _init_lighthouse() -> void:
	var neighbor := Game_CoordCalculator.get_neighbor(
			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y,
			Game_StyxData.LIGHTHOUSE_GAP, true)

	_add_building_to_blueprint(_spr_Lighthouse, Game_SubTag.LIGHTHOUSE,
			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y)
	for i in neighbor:
		_occupy_position(i.x, i.y)


func _init_harbor() -> void:
	var neighbor: Array
	var x: int
	var y: int

	neighbor = Game_CoordCalculator.get_neighbor(PC_X, PC_Y,
			Game_StyxData.NORMAL_SIGHT, true)
	for i in neighbor:
		_set_terrain_marker(i.x, i.y, HARBOR_MARKER)

	for _i in range(0, Game_StyxData.MAX_HARBOR):
		while true:
			x = _ref_RandomNumber.get_x_coord()
			y = _ref_RandomNumber.get_y_coord()
			if _is_occupied(x, y) or _is_terrain_marker(x, y, HARBOR_MARKER):
				continue
			break

		_add_building_to_blueprint(_spr_Harbor, Game_SubTag.HARBOR, x, y)
		_occupy_position(x, y)
		neighbor = Game_CoordCalculator.get_neighbor(x, y,
				Game_StyxData.NORMAL_SIGHT, false)
		for j in neighbor:
			if _is_terrain_marker(j.x, j.y, DEFAULT_MARKER):
				_set_terrain_marker(j.x, j.y, HARBOR_MARKER)


func _init_river() -> void:
	for i in range(Game_DungeonSize.MAX_X):
		for j in range(Game_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				continue
			_add_ground_to_blueprint(_spr_Arrow, Game_SubTag.ARROW, i, j)
