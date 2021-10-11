extends Game_WorldTemplate


const PATH_TO_PREFABS := "ninja"

var _spr_PCNinja := preload("res://sprite/PCNinja.tscn")
# var _spr_Ninja := preload("res://sprite/Ninja.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor()
	# _create_actor()
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
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					_occupy_position(x, y)
					_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL,
							x, y)


# func _create_wall() -> void:
# 	var file_list: Array = Game_FileIOHelper.get_file_list(
# 			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
# 	var edit_prefab := [
# 		Game_DungeonPrefab.HORIZONTAL_FLIP,
# 		Game_DungeonPrefab.VERTICAL_FLIP,
# 	]
# 	var packed_prefab: Game_DungeonPrefab.PackedPrefab
# 	var optional_walls := []

# 	for _i in range(edit_prefab.size()):
# 		edit_prefab.push_back(Game_DungeonPrefab.DO_NOT_EDIT)
# 	Game_ArrayHelper.rand_picker(file_list, MAX_PREFAB, _ref_RandomNumber)
# 	Game_ArrayHelper.rand_picker(edit_prefab, MAX_PREFAB_ARG, _ref_RandomNumber)
# 	# print(file_list[0])
# 	packed_prefab = Game_DungeonPrefab.get_prefab(file_list[0], edit_prefab)

# 	for x in range(0, packed_prefab.max_x):
# 		for y in range(0, packed_prefab.max_y):
# 			match packed_prefab.prefab[x][y]:
# 				Game_DungeonPrefab.WALL_CHAR:
# 					_occupy_position(x, y)
# 					_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL,
# 							x, y)
# 				OPTIONAL_WALL_CHAR:
# 					optional_walls.push_back([x, y])

# 	Game_ArrayHelper.rand_picker(optional_walls,
# 			floor(optional_walls.size() / 2.0) as int, _ref_RandomNumber)
# 	for i in optional_walls:
# 		_occupy_position(i[0], i[1])
# 		_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, i[0], i[1])


# func _create_actor() -> void:
# 	var x: int
# 	var y: int
# 	var actor_position: Array

# 	actor_position = Game_CoordCalculator.get_neighbor(
# 			Game_DungeonSize.CENTER_X, Game_DungeonSize.CENTER_Y,
# 			Game_NinjaData.PC_SIGHT, true)
# 	Game_ArrayHelper.shuffle(actor_position, _ref_RandomNumber)
# 	for i in actor_position:
# 		if not _is_occupied(i[0], i[1]):
# 			x = i[0]
# 			y = i[1]
# 			break

# 	actor_position = Game_CoordCalculator.get_neighbor(x, y,
# 			Game_NinjaData.MAX_DISTANCE_TO_PC)
# 	Game_ArrayHelper.filter_element(actor_position, self,
# 			"_not_too_close_to_pc", [x, y])
# 	Game_ArrayHelper.rand_picker(actor_position, Game_NinjaData.MAX_NPC,
# 			_ref_RandomNumber)

# 	_add_actor_to_blueprint(_spr_PCNinja, Game_SubTag.PC, x, y)
# 	for i in actor_position:
# 		_add_actor_to_blueprint(_spr_Ninja, Game_SubTag.NINJA, i[0], i[1])


# func _not_too_close_to_pc(source: Array, index: int, opt_arg: Array) -> bool:
# 	var x: int = source[index][0]
# 	var y: int = source[index][1]
# 	var pc_x: int = opt_arg[0]
# 	var pc_y: int = opt_arg[1]

# 	return not (_is_occupied(x, y) \
# 			or Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
# 					Game_NinjaData.MIN_DISTANCE_TO_PC))
