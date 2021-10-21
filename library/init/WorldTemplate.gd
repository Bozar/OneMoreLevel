class_name Game_WorldTemplate
# Scripts such as Init[DungeonType].gd inherit this script.
# Override get_blueprint() and _init_dungeon_board().
# The child should also implement _init() to pass arguments.


const INVALID_COORD := -99
const DEFAULT_MARKER := 0
const OCCUPIED_MARKER := 1

const MAX_WHILE_TRUE_RETRY := 1000

var _spr_Floor := preload("res://sprite/Floor.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")
var _spr_PC := preload("res://sprite/PC.tscn")

var _ref_RandomNumber: Game_RandomNumber
var _ref_DangerZone: Game_DangerZone

# {0: [0, ...], 1: [0, ...], ...}
var _dungeon_board := {}
# [SpriteBlueprint, ...]
var _blueprint := []


func _init(parent_node: Node2D) -> void:
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_DangerZone = parent_node._ref_DangerZone

	_init_dungeon_board()


# Child scripts should implement _init() to pass arguments.
# func _init(_random: RandomNumber).(_random) -> void:
# 	pass


# Override.
func get_blueprint() -> Array:
	return _blueprint


func clear_blueprint() -> void:
	_dungeon_board.clear()
	_blueprint.clear()


func _init_dungeon_board() -> void:
	for i in range(Game_DungeonSize.MAX_X):
		_dungeon_board[i] = []
		_dungeon_board[i].resize(Game_DungeonSize.MAX_Y)
		for j in range(Game_DungeonSize.MAX_Y):
			_dungeon_board[i][j] = DEFAULT_MARKER


func _occupy_position(x: int, y: int) -> void:
	_dungeon_board[x][y] = OCCUPIED_MARKER


func _reverse_occupy(x: int, y: int) -> void:
	var new_marker: int = DEFAULT_MARKER \
			if _dungeon_board[x][y] == OCCUPIED_MARKER \
			else OCCUPIED_MARKER
	_dungeon_board[x][y] = new_marker


func _is_occupied(x: int, y: int) -> bool:
	return _dungeon_board[x][y] == OCCUPIED_MARKER


func _set_terrain_marker(x: int, y: int, marker: int) -> void:
	_dungeon_board[x][y] = marker


func _get_terrain_marker(x: int, y: int) -> int:
	return _dungeon_board[x][y]


func _is_terrain_marker(x: int, y: int, marker: int) -> bool:
	return _dungeon_board[x][y] == marker


func _add_to_blueprint(scene: PackedScene, main_tag: String, sub_tag: String,
		x: int, y: int) -> void:
	_blueprint.push_back(Game_SpriteBlueprint.new(scene, main_tag, sub_tag,
			x, y))


func _add_ground_to_blueprint(scene: PackedScene, sub_tag: String,
		x: int, y: int) -> void:
	_add_to_blueprint(scene, Game_MainTag.GROUND, sub_tag, x, y)


func _add_trap_to_blueprint(scene: PackedScene, sub_tag: String,
		x: int, y: int) -> void:
	_add_to_blueprint(scene, Game_MainTag.TRAP, sub_tag, x, y)


func _add_building_to_blueprint(scene: PackedScene, sub_tag: String,
		x: int, y: int) -> void:
	_add_to_blueprint(scene, Game_MainTag.BUILDING, sub_tag, x, y)


func _add_actor_to_blueprint(scene: PackedScene, sub_tag: String,
		x: int, y: int) -> void:
	_add_to_blueprint(scene, Game_MainTag.ACTOR, sub_tag, x, y)


func _init_floor(floor_sprite: PackedScene = _spr_Floor) -> void:
	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			if _is_occupied(x, y):
				continue
			_add_to_blueprint(floor_sprite,
					Game_MainTag.GROUND, Game_SubTag.FLOOR, x, y)


func _init_actor(min_distance: int, x: int, y: int, max_actor: int,
		actor_scene: PackedScene, sub_tag: String) -> void:
	if max_actor < 1:
		return
	max_actor -= 1

	var neighbor: Array
	var retry := 0

	while true:
		if retry > MAX_WHILE_TRUE_RETRY:
			print("_init_actor(): Too many retries.")
			return
		retry += 1
		if Game_CoordCalculator.is_inside_dungeon(x, y) \
				and (not _is_occupied(x, y)):
			break
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()

	neighbor = Game_CoordCalculator.get_neighbor(x, y, min_distance, true)
	for i in neighbor:
		_occupy_position(i.x, i.y)
	_add_to_blueprint(actor_scene, Game_MainTag.ACTOR, sub_tag, x, y)

	_init_actor(min_distance, x, y, max_actor, actor_scene, sub_tag)


func _init_pc(min_distance: int = 0,
		x: int = INVALID_COORD, y: int = INVALID_COORD,
		pc_scene: PackedScene = _spr_PC) -> void:
	_init_actor(min_distance, x, y, 1, pc_scene, Game_SubTag.PC)
