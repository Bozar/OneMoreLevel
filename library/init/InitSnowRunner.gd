extends Game_WorldTemplate


const PATH_TO_PREFABS := "snowrunner"

const DOOR_CHAR := "+"
const CROSSROAD_CHAR := "="
const ONLOAD_GOODS_CHAR := "G"
const OFFLOAD_GOODS_CHAR := "X"
const START_CHAR := "S"

var _spr_DoorTruck := preload("res://sprite/DoorTruck.tscn")
var _spr_FloorSnowRunner := preload("res://sprite/FloorSnowRunner.tscn")
# var _spr_Crystal := preload("res://sprite/Crystal.tscn")
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
	var create_this: bool
	# var ground_coords := []
	var door_coords := []
	var offload_coords := []

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			create_this = true
			match packed_prefab.prefab[x][y]:
				DOOR_CHAR:
					door_coords.push_back(Game_IntCoord.new(x, y))
					create_this = false
				OFFLOAD_GOODS_CHAR:
					offload_coords.push_back(Game_IntCoord.new(x, y))
					create_this = false
				Game_DungeonPrefab.WALL_CHAR:
					new_scene = _spr_Wall
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.WALL
				ONLOAD_GOODS_CHAR:
					new_scene = _spr_OnloadGoods
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.ONLOAD_GOODS
				CROSSROAD_CHAR:
					new_scene = _spr_FloorSnowRunner
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.CROSSROAD
					# ground_coords.push_back(Game_IntCoord.new(x, y))
				_:
					new_scene = _spr_Floor
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.FLOOR
					# ground_coords.push_back(Game_IntCoord.new(x, y))
					if packed_prefab.prefab[x][y] == START_CHAR:
						_pc_x = x
						_pc_y = y
			if create_this:
				_add_to_blueprint(new_scene, main_tag, sub_tag, x, y)

	# Create snow.
	# Game_ArrayHelper.rand_picker(ground_coords, Game_SnowRunnerData.MAX_SNOW,
	# 		_ref_RandomNumber)
	# for i in ground_coords:
	# 	_add_trap_to_blueprint(_spr_Crystal, Game_SubTag.SNOW, i.x, i.y)

	# Create offload doors. They are shown as ordinary doors when game starts.
	# Refer: SnowRunnerProgress.end_world().
	Game_ArrayHelper.shuffle(offload_coords, _ref_RandomNumber)
	for i in range(0, offload_coords.size()):
		if i < Game_SnowRunnerData.MAX_DELIVERY:
			_add_building_to_blueprint(_spr_DoorTruck,
					Game_SubTag.OFFLOAD_GOODS,
					offload_coords[i].x, offload_coords[i].y)
		else:
			door_coords.push_back(offload_coords[i])

	# Create doors. Replace some of them with walls.
	_create_building_by_threshold(door_coords, Game_SnowRunnerData.MAX_DOOR,
			_spr_DoorTruck, Game_SubTag.DOOR,
			_spr_Wall, Game_SubTag.WALL)
	# print(door_coords.size())


func _create_building_by_threshold(coords: Array, max_building: int,
		this_scene: PackedScene, this_sub_tag: String,
		that_scene: PackedScene, that_sub_tag: String) -> void:
	var new_scene: PackedScene
	var new_sub_tag: String

	Game_ArrayHelper.shuffle(coords, _ref_RandomNumber)
	for i in range(0, coords.size()):
		if i < max_building:
			new_scene = this_scene
			new_sub_tag = this_sub_tag
		else:
			new_scene = that_scene
			new_sub_tag = that_sub_tag
		_add_building_to_blueprint(new_scene, new_sub_tag,
				coords[i].x, coords[i].y)
