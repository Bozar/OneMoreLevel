extends Game_WorldTemplate


const PATH_TO_PREFABS := "snowrunner"

const DOOR_CHAR := "+"
const CROSSROAD_CHAR := "="
const ONLOAD_GOODS_CHAR := "G"
const OFFLOAD_GOODS_CHAR := "X"
const START_CHAR := "S"

var _spr_DoorTruck := preload("res://sprite/DoorTruck.tscn")
var _spr_FloorSnowRunner := preload("res://sprite/FloorSnowRunner.tscn")
var _spr_Crystal := preload("res://sprite/Crystal.tscn")
var _spr_OnloadGoods := preload("res://sprite/OnloadGoods.tscn")
var _spr_OffloadGoods := preload("res://sprite/OffloadGoods.tscn")
var _spr_PCSnowRunner := preload("res://sprite/PCSnowRunner.tscn")

var _pc_x: int
var _pc_y: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_building_ground()
	_init_pc(0, _pc_x, _pc_y, _spr_PCSnowRunner)

	return _blueprint


func _create_building_ground() -> void:
	var file_list := Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab := Game_DungeonPrefab.get_prefab(file_list[0], [])
	var new_scene: PackedScene
	var main_tag: String
	var sub_tag: String
	var ground_coords := []

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					new_scene = _spr_Wall
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.WALL
				DOOR_CHAR:
					new_scene = _spr_DoorTruck
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.DOOR
				ONLOAD_GOODS_CHAR:
					new_scene = _spr_OnloadGoods
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.ONLOAD_GOODS
				OFFLOAD_GOODS_CHAR:
					new_scene = _spr_OffloadGoods
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.OFFLOAD_GOODS
				CROSSROAD_CHAR:
					new_scene = _spr_FloorSnowRunner
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.CROSSROAD
					ground_coords.push_back(Game_IntCoord.new(x, y))
				_:
					new_scene = _spr_Floor
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.FLOOR
					ground_coords.push_back(Game_IntCoord.new(x, y))
					if packed_prefab.prefab[x][y] == START_CHAR:
						_pc_x = x
						_pc_y = y
			_add_to_blueprint(new_scene, main_tag, sub_tag, x, y)

	Game_ArrayHelper.shuffle(ground_coords, _ref_RandomNumber)
	for i in range(0, Game_SnowRunnerData.SNOWFALL):
		_add_trap_to_blueprint(_spr_Crystal, Game_SubTag.SNOW,
				ground_coords[i].x, ground_coords[i].y)
