extends Game_WorldTemplate


var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")
var _spr_Arrow := preload("res://sprite/Arrow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_building()
	_init_river()
	_init_pc(0, 1, Game_DungeonSize.MAX_Y - 2)

	return _blueprint


func _init_building() -> void:
	var lighthouse_x: int = Game_DungeonSize.CENTER_X
	var lighthouse_y: int = Game_DungeonSize.CENTER_Y
	var harbor: Array = [
		[1, 1],
		[Game_DungeonSize.MAX_X - 2, 1],
		[Game_DungeonSize.MAX_X - 2, Game_DungeonSize.MAX_Y - 2],
	]

	_add_building_to_blueprint(_spr_Lighthouse, Game_SubTag.LIGHTHOUSE,
			lighthouse_x, lighthouse_y)
	_set_static_area(lighthouse_x, lighthouse_y, Game_StyxData.LIGHTHOUSE)

	for i in harbor:
		_add_building_to_blueprint(_spr_Harbor, Game_SubTag.HARBOR, i[0], i[1])
		_set_static_area(i[0], i[1], Game_StyxData.HARBOR)


func _set_static_area(x: int, y: int, max_range: int) -> void:
	var neighbor: Array = Game_CoordCalculator.get_neighbor(x, y, max_range,
			true)

	for i in neighbor:
		_occupy_position(i[0], i[1])


func _init_river() -> void:
	for i in range(Game_DungeonSize.MAX_X):
		for j in range(Game_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				continue
			_add_ground_to_blueprint(_spr_Arrow, Game_SubTag.ARROW, i, j)
