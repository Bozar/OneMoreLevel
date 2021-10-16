extends Game_WorldTemplate


const PATH_TO_PREFABS := "ninja"

var _spr_FloorNinja := preload("res://sprite/FloorNinja.tscn")
var _spr_PCNinja := preload("res://sprite/PCNinja.tscn")
var _spr_Ninja := preload("res://sprite/Ninja.tscn")
var _spr_WallNinja := preload("res://sprite/WallNinja.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor(_spr_FloorNinja)
	_create_actor()
	_init_pc(0, Game_DungeonSize.CENTER_X, Game_NinjaData.MAX_Y - 1,
			_spr_PCNinja)

	return _blueprint


func _create_wall() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab \
			= Game_DungeonPrefab.get_prefab(file_list[0], [])

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			if packed_prefab.prefab[x][y] == Game_DungeonPrefab.WALL_CHAR:
				_occupy_position(x, y)
				_add_building_to_blueprint(_spr_WallNinja, Game_SubTag.WALL,
						x, y)


func _create_actor() -> void:
	var _ninja_pos := [
		[Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y],
		[Game_DungeonSize.CENTER_X - 1, Game_DungeonSize.CENTER_Y - 2],
		[Game_DungeonSize.CENTER_X - 1, Game_DungeonSize.CENTER_Y - 3],
		[Game_DungeonSize.CENTER_X - 1, Game_NinjaData.GROUND_Y],
		[Game_NinjaData.MIN_X, Game_NinjaData.GROUND_Y],
		[Game_DungeonSize.CENTER_X, Game_NinjaData.GROUND_Y - 3],
	]
	for i in _ninja_pos:
		_add_actor_to_blueprint(_spr_Ninja, Game_SubTag.NINJA, i[0], i[1])
