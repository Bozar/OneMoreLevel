extends Game_WorldTemplate


const PATH_TO_PREFABS := Game_DungeonPrefab.RESOURCE_PATH + "baron"
const MAX_PREFAB := 9
const FLIP_CHANCE := 50
const X_STEP := 7
const Y_STEP := 5
const CHAR_TRUNK := "O"
const CHAR_BRANCH := "+"

enum {
	BRANCH = DEFAULT_MARKER + 1, TRUNK, BANDIT, BIRD,
}

var _spr_TreeTrunk := preload("res://sprite/TreeTrunk.tscn")
var _spr_TreeBranch := preload("res://sprite/TreeBranch.tscn")
var _spr_PCBaron := preload("res://sprite/PCBaron.tscn")
var _spr_Bird := preload("res://sprite/Bird.tscn")
var _spr_Bandit := preload("res://sprite/Bandit.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	var terrain_map := _create_tree_floor()

	_create_bandit(terrain_map[BANDIT])
	_create_pc(terrain_map[BIRD], terrain_map[BANDIT])
	_create_bird(terrain_map[BIRD])

	return _blueprint


func _create_tree_floor() -> Dictionary:
	var packed_prefabs: Array = _load_prefabs()
	var prefab_index := 0
	var this_prefab: Game_DungeonPrefab.PackedPrefab
	var terrain := {BIRD: [], BANDIT: [],}

	for start_x in range(0, Game_DungeonSize.MAX_X, X_STEP):
		for start_y in range(0, Game_DungeonSize.MAX_Y, Y_STEP):
			this_prefab = packed_prefabs[prefab_index]
			prefab_index += 1
			_parse_prefab(this_prefab, start_x, start_y, terrain)
	return terrain


func _load_prefabs() -> Array:
	var file_list: Array = Game_FileIOHelper.get_file_list(PATH_TO_PREFABS)
	var edit_arg: Array
	var packed_prefabs := []

	# There must be more than MAX_PREFAB prefabs.
	Game_ArrayHelper.rand_picker(file_list, MAX_PREFAB, _ref_RandomNumber)
	for i in file_list:
		# print(i)
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


func _parse_prefab(this_prefab: Game_DungeonPrefab.PackedPrefab,
		start_x: int, start_y: int, terrain: Dictionary) -> void:
	var this_char: String
	var this_x: int
	var this_y: int
	var is_tree: bool
	var is_ground: bool
	var grounds := []

	for x in this_prefab.max_x:
		for y in this_prefab.max_y:
			this_char = this_prefab.prefab[x][y]
			this_x = x + start_x
			this_y = y + start_y
			is_tree = true
			is_ground = true

			match this_char:
				CHAR_TRUNK:
					_add_building_to_blueprint(_spr_TreeTrunk,
							Game_SubTag.TREE_TRUNK, this_x, this_y)
					is_ground = false
				CHAR_BRANCH:
					_add_building_to_blueprint(_spr_TreeBranch,
							Game_SubTag.TREE_BRANCH, this_x, this_y)
				_:
					_add_ground_to_blueprint(_spr_Floor,
							Game_SubTag.FLOOR, this_x, this_y)
					is_tree = false

			if is_tree:
				terrain[BIRD].push_back(Game_IntCoord.new(this_x, this_y))
			if is_ground:
				grounds.push_back(Game_IntCoord.new(this_x, this_y))

	Game_ArrayHelper.shuffle(grounds, _ref_RandomNumber)
	terrain[BANDIT].push_back(grounds.pop_back())


func _create_pc(terrain_map: Array, bandit_map: Array) -> void:
	var goto_next: bool
	var pc_pos: Game_IntCoord

	Game_ArrayHelper.shuffle(terrain_map, _ref_RandomNumber)
	for i in range(0, terrain_map.size()):
		goto_next = false
		for j in bandit_map:
			if Game_CoordCalculator.is_in_range(j, terrain_map[i],
					Game_BaronData.BASE_SIGHT):
				goto_next = true
				break
		if goto_next:
			continue
		Game_ArrayHelper.swap_element(terrain_map, i, terrain_map.size() - 1)
		break
	# Even if all grids are within Y_STEP to bandits, the last element in
	# terrain_map is still a tree grid and therefore is available.
	pc_pos = terrain_map.pop_back()
	_add_actor_to_blueprint(_spr_PCBaron, Game_SubTag.PC, pc_pos.x, pc_pos.y,
			Game_BaronData.TREE_LAYER)


func _create_bird(terrain_map: Array) -> void:
	var count_bird := 0

	for i in terrain_map:
		if count_bird >= Game_BaronData.MAX_BIRD:
			break
		if _is_terrain_marker(i.x, i.y, BIRD):
			continue

		count_bird += 1
		_add_actor_to_blueprint(_spr_Bird, Game_SubTag.BIRD, i.x, i.y,
				Game_BaronData.TREE_LAYER)
		for j in Game_CoordCalculator.get_neighbor(i,
				Game_BaronData.MIN_BIRD_GAP, true):
			_set_terrain_marker(j.x, j.y, BIRD)


func _create_bandit(terrain_map: Array) -> void:
	Game_ArrayHelper.rand_picker(terrain_map, Game_BaronData.MAX_BANDIT,
			_ref_RandomNumber)
	for i in terrain_map:
		_add_actor_to_blueprint(_spr_Bandit, Game_SubTag.BANDIT, i.x, i.y)
