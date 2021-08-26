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
	var edit_prefab := [
		Game_DungeonPrefab.HORIZONTAL_FLIP,
		Game_DungeonPrefab.VERTICAL_FLIP,
		Game_DungeonPrefab.ROTATE_RIGHT,
	]

	for _i in range(edit_prefab.size()):
		edit_prefab.push_back(Game_DungeonPrefab.DO_NOT_EDIT)
	Game_ArrayHelper.rand_picker(edit_prefab, MAX_PREFAB_ARG, _ref_RandomNumber)
	packed_prefab = Game_DungeonPrefab.get_prefab(file_list[0], edit_prefab)

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					_occupy_position(x + start_x, y + start_y)
					_add_to_blueprint(_spr_Wall, Game_MainTag.BUILDING,
							Game_SubTag.WALL, x + start_x, y + start_y)
				DOOR_CHAR:
					_occupy_position(x + start_x, y + start_y)
					_add_to_blueprint(_spr_Door, Game_MainTag.BUILDING,
							Game_SubTag.DOOR, x + start_x, y + start_y)
