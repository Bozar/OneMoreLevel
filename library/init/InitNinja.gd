extends Game_WorldTemplate


const PATH_TO_PREFABS := "ninja"
const HP_CHAR := "X"

const RANGE_Y := [
	[Game_NinjaData.LEVEL_2_Y, Game_NinjaData.LEVEL_3_Y],
	[Game_NinjaData.LEVEL_1_Y, Game_NinjaData.LEVEL_2_Y],
	[Game_NinjaData.MIN_Y, Game_NinjaData.LEVEL_1_Y],
]

var _spr_FloorNinja := preload("res://sprite/FloorNinja.tscn")
var _spr_HPBar := preload("res://sprite/HPBar.tscn")
var _spr_PCNinja := preload("res://sprite/PCNinja.tscn")
var _spr_Ninja := preload("res://sprite/Ninja.tscn")
var _spr_WallNinja := preload("res://sprite/WallNinja.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall_floor()
	_init_floor(_spr_FloorNinja)
	_init_pc(1, Game_DungeonSize.CENTER_X, Game_NinjaData.MAX_Y - 1,
			_spr_PCNinja)
	_create_actor()

	return BLUEPRINT


func _create_wall_floor() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab: Game_DungeonPrefab.PackedPrefab \
			= Game_DungeonPrefab.get_prefab(file_list[0], [])
	var new_scene: PackedScene
	var sub_tag: String

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			_occupy_position(x, y)
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					new_scene = _spr_WallNinja
					sub_tag = Game_SubTag.WALL
					_add_building_to_blueprint(new_scene, sub_tag, x, y)
				HP_CHAR:
					new_scene = _spr_HPBar
					sub_tag = Game_SubTag.FLOOR
					_add_ground_to_blueprint(new_scene, sub_tag, x, y)
				_:
					_reverse_occupy(x, y)


func _create_actor() -> void:
	for i in RANGE_Y:
		_create_actor_in_one_region(i[0], i[1],
				Game_NinjaData.MAX_NINJA_PER_LEVEL)


func _create_actor_in_one_region(min_y: int, max_y: int, count: int) -> void:
	if count < 1:
		return

	var x := _ref_RandomNumber.get_int(Game_NinjaData.MIN_X,
			Game_NinjaData.MAX_X)
	var y := _ref_RandomNumber.get_int(min_y, max_y)
	var neighbor: Array

	if _is_occupied(x, y):
		_create_actor_in_one_region(min_y, max_y, count)
	else:
		_add_actor_to_blueprint(_spr_Ninja, Game_SubTag.NINJA, x, y)
		neighbor = Game_CoordCalculator.get_neighbor_xy(x, y, 1, true)
		for i in neighbor:
			_occupy_position(i.x, i.y)
		_create_actor_in_one_region(min_y, max_y, count - 1)
