extends Game_WorldTemplate


const PATH_TO_PREFABS := "baron"
const MAX_PREFAB := 9
const FLIP_CHANCE := 50
const X_STEP := 7
const Y_STEP := 5
const CHAR_TRUNK := "O"
const CHAR_BRANCH := "+"

var _spr_TreeTrunk := preload("res://sprite/TreeTrunk.tscn")
var _spr_TreeBranch := preload("res://sprite/TreeBranch.tscn")

var _char_to_blueprint := {
	CHAR_TRUNK: [_spr_TreeTrunk, Game_SubTag.TREE_TRUNK],
	CHAR_BRANCH: [_spr_TreeBranch, Game_SubTag.TREE_BRANCH],
}


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_tree()
	_init_floor()
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


func _load_prefabs() -> Array:
	var file_list: Array = Game_FileIOHelper.get_file_list(
			Game_DungeonPrefab.RESOURCE_PATH + PATH_TO_PREFABS)
	var file_index: int
	var edit_arg: Array
	var packed_prefabs := []

	for _i in range(0, MAX_PREFAB):
		file_index = _ref_RandomNumber.get_int(0, file_list.size())
		edit_arg = [
			Game_DungeonPrefab.HORIZONTAL_FLIP \
					if _ref_RandomNumber.get_percent_chance(FLIP_CHANCE) \
					else Game_DungeonPrefab.DO_NOT_EDIT,
			Game_DungeonPrefab.VERTICAL_FLIP \
					if _ref_RandomNumber.get_percent_chance(FLIP_CHANCE) \
					else Game_DungeonPrefab.DO_NOT_EDIT
		]
		packed_prefabs.push_back(Game_DungeonPrefab.get_prefab(
				file_list[file_index], edit_arg))

	return packed_prefabs
