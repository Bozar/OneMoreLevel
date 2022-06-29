extends Game_WorldTemplate


const PATH_TO_PREFABS := Game_DungeonPrefab.RESOURCE_PATH + "baron"
const MAX_PREFAB := 9
const FLIP_CHANCE := 50
const X_STEP := 7
const Y_STEP := 5
const CHAR_TRUNK := "O"
const CHAR_BRANCH := "+"

enum TERRAIN {
	BRANCH = DEFAULT_MARKER + 1, TRUNK, BANDIT, BIRD,
}

var _spr_TreeTrunk := preload("res://sprite/TreeTrunk.tscn")
var _spr_TreeBranch := preload("res://sprite/TreeBranch.tscn")

var _char_to_blueprint := {
	CHAR_TRUNK: [_spr_TreeTrunk, Game_SubTag.TREE_TRUNK, TERRAIN.TRUNK],
	CHAR_BRANCH: [_spr_TreeBranch, Game_SubTag.TREE_BRANCH, TERRAIN.BRANCH],
}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_tree()
	_create_floor()
	_init_pc()

	return _blueprint


func _init_tree() -> void:
	var packed_prefabs: Array = _load_prefabs()
	var prefab_index := 0
	var this_prefab: Game_DungeonPrefab.PackedPrefab
	var this_char: String

	for start_x in range(0, Game_DungeonSize.MAX_X, X_STEP):
		for start_y in range(0, Game_DungeonSize.MAX_Y, Y_STEP):
			this_prefab = packed_prefabs[prefab_index]
			prefab_index += 1

			for x in this_prefab.max_x:
				for y in this_prefab.max_y:
					this_char = this_prefab.prefab[x][y]
					if _char_to_blueprint.has(this_char):
						_add_building_to_blueprint(
								_char_to_blueprint[this_char][0],
								_char_to_blueprint[this_char][1],
								x + start_x, y + start_y)
						_set_terrain_marker(x + start_x, y + start_y,
								_char_to_blueprint[this_char][2])


func _load_prefabs() -> Array:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_PREFABS)
	var edit_arg: Array
	var packed_prefabs := []

	# There must be more than MAX_PREFAB prefabs.
	Game_ArrayHelper.rand_picker(file_list, MAX_PREFAB, _ref_RandomNumber)
	for i in file_list:
		edit_arg = [
			Game_DungeonPrefab.HORIZONTAL_FLIP \
					if _ref_RandomNumber.get_percent_chance(FLIP_CHANCE) \
					else Game_DungeonPrefab.DO_NOT_EDIT,
			Game_DungeonPrefab.VERTICAL_FLIP \
					if _ref_RandomNumber.get_percent_chance(FLIP_CHANCE) \
					else Game_DungeonPrefab.DO_NOT_EDIT
		]
		packed_prefabs.push_back(Game_DungeonPrefab.get_prefab(i, edit_arg))

	return packed_prefabs


func _create_floor() -> void:
	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			if _get_terrain_marker(x, y) > DEFAULT_MARKER:
				continue
			_add_ground_to_blueprint(_spr_Floor, Game_SubTag.FLOOR, x, y)
