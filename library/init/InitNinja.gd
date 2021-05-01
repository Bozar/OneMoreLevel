extends Game_WorldTemplate


var _new_DungeonPrefab := Game_DungeonPrefab.new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_floor()
	_init_pc()

	return _blueprint


func _init_wall() -> void:
	var new_file: String = Game_FileIOHelper.get_file_list(
			_new_DungeonPrefab.RESOURCE_PATH + "ninja")[0]
	var dungeon_prefab: Dictionary = _new_DungeonPrefab.get_prefab(new_file)

	for y in dungeon_prefab.keys().size():
		for x in dungeon_prefab[0].length():
			if dungeon_prefab[y][x] == _new_DungeonPrefab.WALL:
				_occupy_position(x, y)
				_add_to_blueprint(_spr_Wall,
						Game_MainGroupTag.BUILDING, Game_SubGroupTag.WALL, x, y)
