extends Game_WorldTemplate


const PATH_TO_PREFABS := "snowrunner"

const DOOR_CHAR := "+"
const CROSSROAD_CHAR := "="

var _spr_Door := preload("res://sprite/Door.tscn")
var _spr_Arrow := preload("res://sprite/Arrow.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_building_ground()
	_init_pc(0, Game_DungeonSize.CENTER_X + 1, Game_DungeonSize.CENTER_Y - 3,
			_spr_Arrow)

	return _blueprint


func _create_building_ground() -> void:
	var file_list := Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var packed_prefab := Game_DungeonPrefab.get_prefab(file_list[0], [])
	var new_scene: PackedScene
	var main_tag: String
	var sub_tag: String

	for x in range(0, packed_prefab.max_x):
		for y in range(0, packed_prefab.max_y):
			match packed_prefab.prefab[x][y]:
				Game_DungeonPrefab.WALL_CHAR:
					new_scene = _spr_Wall
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.WALL
				DOOR_CHAR:
					new_scene = _spr_Door
					main_tag = Game_MainTag.BUILDING
					sub_tag = Game_SubTag.DOOR
				CROSSROAD_CHAR:
					new_scene = _spr_Floor
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.CROSSROAD
				_:
					new_scene = _spr_Floor
					main_tag = Game_MainTag.GROUND
					sub_tag = Game_SubTag.FLOOR
			_add_to_blueprint(new_scene, main_tag, sub_tag, x, y)
