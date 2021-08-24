extends Game_WorldTemplate


const PATH_TO_PREFABS := "factory"
const DOOR_CHAR := "+"
const FLIP_PREFAB := 50
const MAX_PREFAB_ARG := 3

var _spr_Door := preload("res://sprite/Door.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor()
	_init_pc()

	return _blueprint


func _create_wall() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab
	var start_x := 5
	var start_y := 5
	var prefab_arg := []

	for _i in range(0, MAX_PREFAB_ARG):
		prefab_arg.push_back(_ref_RandomNumber.get_percent_chance(FLIP_PREFAB))
	packed_prefab = Game_DungeonPrefab.get_prefab(file_list[0],
			prefab_arg[0], prefab_arg[1], prefab_arg[2])

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					_occupy_position(x + start_x, y + start_y)
					_add_to_blueprint(_spr_Wall, Game_MainGroupTag.BUILDING,
							Game_SubGroupTag.WALL, x + start_x, y + start_y)
				DOOR_CHAR:
					_occupy_position(x + start_x, y + start_y)
					_add_to_blueprint(_spr_Door, Game_MainGroupTag.BUILDING,
							Game_SubGroupTag.DOOR, x + start_x, y + start_y)
