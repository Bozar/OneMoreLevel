extends Game_WorldTemplate


const PATH_TO_PREFABS: String = "ninja"
const MAX_PREFAB: int = 1
const FLIP_PREFAB: int = 50

var _spr_PCNinja := preload("res://sprite/PCNinja.tscn")
var _spr_Ninja := preload("res://sprite/Ninja.tscn")

var _new_DungeonPrefab := Game_DungeonPrefab.new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor()
	_create_actor()

	return _blueprint


func _create_wall() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			_new_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab

	_new_ArrayHelper.rand_picker(file_list, MAX_PREFAB, _ref_RandomNumber)
	packed_prefab = _new_DungeonPrefab.get_prefab(file_list[0],
			_ref_RandomNumber.get_percent_chance(FLIP_PREFAB),
			_ref_RandomNumber.get_percent_chance(FLIP_PREFAB))

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					_occupy_position(x, y)
					_add_to_blueprint(_spr_Wall, Game_MainGroupTag.BUILDING,
							Game_SubGroupTag.WALL, x, y)


func _create_actor() -> void:
	var x: int = INVALID_COORD
	var y: int = INVALID_COORD
	var npc_position: Array = []

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if (not _new_CoordCalculator.is_inside_dungeon(x, y)) \
				or _is_occupied(x, y):
			continue

		npc_position = _new_CoordCalculator.get_neighbor(x, y,
				Game_NinjaData.MAX_DISTANCE_TO_PC)
		_new_ArrayHelper.filter_element(npc_position, self,
				"_not_too_close_to_pc", [x, y])
		if npc_position.size() > Game_NinjaData.MAX_NPC:
			break

	_add_to_blueprint(_spr_PCNinja,
			Game_MainGroupTag.ACTOR, Game_SubGroupTag.PC, x, y)

	_new_ArrayHelper.rand_picker(npc_position, Game_NinjaData.MAX_NPC,
			_ref_RandomNumber)
	for i in npc_position:
		_add_to_blueprint(_spr_Ninja, Game_MainGroupTag.ACTOR,
				Game_SubGroupTag.NINJA, i[0], i[1])


func _not_too_close_to_pc(source: Array, index: int, opt_arg: Array) -> bool:
	var x: int = source[index][0]
	var y: int = source[index][1]
	var pc_x: int = opt_arg[0]
	var pc_y: int = opt_arg[1]

	return not (_is_occupied(x, y) \
			or _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
					Game_NinjaData.MIN_DISTANCE_TO_PC))
