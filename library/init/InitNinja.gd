extends Game_WorldTemplate


const PATH_TO_PREFABS: String = "ninja"
const TORII_CHAR: String = "X"
const RESPAWN_CHAR: String = "R"
const PC_CHAR: String = "@"
const MAX_PREFAB: int = 1
const MAX_PC: int = 1
const FLIP_PREFAB: int = 50

var _spr_PCNinja := preload("res://sprite/PCNinja.tscn")
var _spr_Torii := preload("res://sprite/Torii.tscn")
var _spr_Ninja := preload("res://sprite/Ninja.tscn")
var _spr_NinjaButterfly := preload("res://sprite/NinjaButterfly.tscn")
var _spr_NinjaShadow := preload("res://sprite/NinjaShadow.tscn")

var _new_DungeonPrefab := Game_DungeonPrefab.new()
var _respawn_position: Array = []
var _pc_position: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_create_floor()
	_create_npc()
	_create_pc()

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
				TORII_CHAR:
					_occupy_position(x, y)
					_add_to_blueprint(_spr_Torii, Game_MainGroupTag.BUILDING,
							Game_SubGroupTag.PILLAR, x, y)
				RESPAWN_CHAR:
					_respawn_position.push_back([x, y])
				PC_CHAR:
					_pc_position.push_back([x, y])


func _create_floor() -> void:
	for i in _respawn_position:
		_add_to_blueprint(_spr_Floor,
				Game_MainGroupTag.GROUND, Game_SubGroupTag.RESPAWN, i[0], i[1])
		_occupy_position(i[0], i[1])
	_init_floor()


func _create_npc() -> void:
	var new_ninja: PackedScene
	var new_sub_tag: String

	_new_ArrayHelper.rand_picker(_respawn_position, Game_NinjaData.MAX_NPC,
			_ref_RandomNumber)
	for i in _respawn_position.size():
		if i < Game_NinjaData.MAX_SHADOW:
			new_ninja = _spr_NinjaShadow
			new_sub_tag = Game_SubGroupTag.SHADOW_NINJA
		elif i < Game_NinjaData.MAX_SHADOW + Game_NinjaData.MAX_BUTTERFLY:
			new_ninja = _spr_NinjaButterfly
			new_sub_tag = Game_SubGroupTag.BUTTERFLY_NINJA
		else:
			new_ninja = _spr_Ninja
			new_sub_tag = Game_SubGroupTag.NINJA
		_add_to_blueprint(new_ninja, Game_MainGroupTag.ACTOR, new_sub_tag,
				_respawn_position[i][0], _respawn_position[i][1])


func _create_pc() -> void:
	_new_ArrayHelper.rand_picker(_pc_position, MAX_PC, _ref_RandomNumber)
	_add_to_blueprint(_spr_PCNinja,
			Game_MainGroupTag.ACTOR, Game_SubGroupTag.PC,
			_pc_position[0][0], _pc_position[0][1])
