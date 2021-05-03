extends Game_WorldTemplate


const PATH_TO_PREFABS: String = "ninja"
const TORII_CHAR: String = "X"
const RESPAWN_CHAR: String = "R"
const PC_CHAR: String = "@"
const MAX_PREFAB: int = 1
const MAX_PC: int = 1
const FLIP_PREFAB: int = 50

var _spr_Portal := preload("res://sprite/Portal.tscn")
var _spr_Dwarf := preload("res://sprite/Dwarf.tscn")

var _new_DungeonPrefab := Game_DungeonPrefab.new()
var _respawn_position: Array = []
var _pc_position: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_wall()
	_create_npc()
	_init_floor()
	_create_pc()

	return _blueprint


func _init_wall() -> void:
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
				TORII_CHAR:
					_occupy_position(x, y)
					_add_to_blueprint(_spr_Portal, Game_MainGroupTag.BUILDING,
							Game_SubGroupTag.PILLAR, x, y)
				RESPAWN_CHAR:
					_respawn_position.push_back([x, y])
				PC_CHAR:
					_pc_position.push_back([x, y])


func _create_npc() -> void:
	_new_ArrayHelper.rand_picker(_respawn_position, _respawn_position.size(),
			_ref_RandomNumber)
	for i in _respawn_position.size():
		if i < Game_NinjaData.MAX_NPC:
			_add_to_blueprint(_spr_Dwarf,
					Game_MainGroupTag.ACTOR, Game_SubGroupTag.DWARF,
					_respawn_position[i][0], _respawn_position[i][1])
		_add_to_blueprint(_spr_Floor,
				Game_MainGroupTag.GROUND, Game_SubGroupTag.RESPAWN,
				_respawn_position[i][0], _respawn_position[i][1])
		_occupy_position(_respawn_position[i][0], _respawn_position[i][1])


func _create_pc() -> void:
	_new_ArrayHelper.rand_picker(_pc_position, MAX_PC, _ref_RandomNumber)
	_add_to_blueprint(_spr_PC, Game_MainGroupTag.ACTOR, Game_SubGroupTag.PC,
			_pc_position[0][0], _pc_position[0][1])
