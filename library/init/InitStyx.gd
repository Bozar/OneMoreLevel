extends Game_WorldTemplate


const HARBOR_MARKER := OCCUPIED_MARKER + 1
const PC_COORD := [
	[1, 1],
	[1, Game_DungeonSize.MAX_Y - 2],
	[Game_DungeonSize.MAX_X - 2, 1],
	[Game_DungeonSize.MAX_X - 2, Game_DungeonSize.MAX_Y - 2],
]

var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")
var _spr_Arrow := preload("res://sprite/Arrow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var coord_index := _ref_RandomNumber.get_int(0, PC_COORD.size())
	var pc_pos: Array = PC_COORD[coord_index]
	var pc_x: int = pc_pos[0]
	var pc_y: int = pc_pos[1]

	_init_lighthouse()
	_init_harbor(pc_x, pc_y)
	_init_river()
	_init_pc(0, pc_x, pc_y)

	return _blueprint


func _init_lighthouse() -> void:
	var neighbor := Game_CoordCalculator.get_neighbor_xy(
			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y,
			Game_StyxData.LIGHTHOUSE_GAP, true)

	_add_building_to_blueprint(_spr_Lighthouse, Game_SubTag.LIGHTHOUSE,
			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y)
	for i in neighbor:
		_occupy_position(i.x, i.y)


func _init_harbor(pc_x: int, pc_y: int) -> void:
	for i in Game_CoordCalculator.get_neighbor_xy(pc_x, pc_y,
			Game_StyxData.HARBOR_GAP, true):
		_set_terrain_marker(i.x, i.y, HARBOR_MARKER)

	Game_WorldGenerator.create_by_coord(_all_coords,
			Game_StyxData.MAX_HARBOR, _ref_RandomNumber, self,
			"_is_valid_harbor_coord", [],
			"_create_harbor_here", [])


func _init_river() -> void:
	for i in range(Game_DungeonSize.MAX_X):
		for j in range(Game_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				continue
			_add_ground_to_blueprint(_spr_Arrow, Game_SubTag.ARROW, i, j)


func _is_valid_harbor_coord(coord: Game_IntCoord, _retry: int, _arg: Array) \
		-> bool:
	if _is_terrain_marker(coord.x, coord.y, HARBOR_MARKER) \
			or _is_occupied(coord.x, coord.y):
		return false
	return true


func _create_harbor_here(coord: Game_IntCoord, _arg: Array) -> void:
	_add_building_to_blueprint(_spr_Harbor, Game_SubTag.HARBOR,
			coord.x, coord.y)
	_occupy_position(coord.x, coord.y)
	for i in Game_CoordCalculator.get_neighbor(coord,
			Game_StyxData.HARBOR_GAP, false):
		if _is_terrain_marker(i.x, i.y, DEFAULT_MARKER):
			_set_terrain_marker(i.x, i.y, HARBOR_MARKER)
