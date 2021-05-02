extends Game_WorldTemplate


const PATH_TO_WALL: String = "ninja"
const PATH_TO_TORII: String = "ninja/torii"
const TORII_CHAR: String = "X"
const PREFAB_WIDTH: int = 7
const PREFAB_HEIGHT: int = 5
const MAX_PREFAB: int = 9
const MAX_TORII: int = 1
const FLIP_PREFAB: int = 50

var _spr_Portal := preload("res://sprite/Portal.tscn")

var _new_DungeonPrefab := Game_DungeonPrefab.new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_init_floor()
	_init_pc()

	return _blueprint


func _init_wall() -> void:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			_new_DungeonPrefab.RESOURCE_PATH + PATH_TO_WALL)
	var torii_list: Array = Game_FileIOHelper.get_file_list(
			_new_DungeonPrefab.RESOURCE_PATH + PATH_TO_TORII)
	var building: Game_DungeonPrefab.PackedPrefab
	var start_x: int = 0
	var start_y: int = 0
	var create_sprite: bool
	var new_sprite: PackedScene
	var new_sub_tag: String

	_new_ArrayHelper.rand_picker(file_list, MAX_PREFAB, _ref_RandomNumber)
	_new_ArrayHelper.rand_picker(torii_list, MAX_TORII, _ref_RandomNumber)
	# file_list[_ref_RandomNumber.get_int(0, MAX_PREFAB)] = torii_list[0]

	for i in file_list:
		building = _new_DungeonPrefab.get_prefab(i,
				_ref_RandomNumber.get_percent_chance(FLIP_PREFAB),
				_ref_RandomNumber.get_percent_chance(FLIP_PREFAB))

		if start_x > Game_DungeonSize.MAX_X - 1:
			start_x = 0
			start_y += PREFAB_HEIGHT

		for x in range(0, building.max_x):
			for y in range(0, building.max_y):
				if building.prefab[x][y] == Game_DungeonPrefab.WALL_CHAR:
					create_sprite = true
					new_sprite = _spr_Wall
					new_sub_tag = Game_SubGroupTag.WALL
				elif building.prefab[x][y] == TORII_CHAR:
					create_sprite = true
					new_sprite = _spr_Portal
					new_sub_tag = Game_SubGroupTag.PILLAR
				else:
					create_sprite = false
				if create_sprite:
					_occupy_position(start_x + x, start_y + y)
					_add_to_blueprint(new_sprite,
							Game_MainGroupTag.BUILDING, new_sub_tag,
							start_x + x, start_y + y)
		start_x += PREFAB_WIDTH
