class_name Game_AITemplate


const INVALID_START_POINT: String = "Unreachable start point."

var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: Game_ObjectData
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_RandomNumber: Game_RandomNumber
var _ref_RemoveObject : Game_RemoveObject
var _ref_CountDown : Game_CountDown
var _ref_CreateObject : Game_CreateObject
var _ref_Schedule: Game_Schedule
var _ref_Palette: Game_Palette

var _self: Sprite
var _pc_pos: Array
var _self_pos: Array
var _target_pos: Array
var _dungeon: Dictionary


# Refer: EnemyAI.gd.
func _init(parent_node: Node2D) -> void:
	_ref_ObjectData = parent_node._ref_ObjectData
	_ref_DungeonBoard = parent_node._ref_DungeonBoard
	_ref_SwitchSprite = parent_node._ref_SwitchSprite
	_ref_DangerZone = parent_node._ref_DangerZone
	_ref_EndGame = parent_node._ref_EndGame
	_ref_RandomNumber = parent_node._ref_RandomNumber
	_ref_RemoveObject = parent_node._ref_RemoveObject
	_ref_CountDown = parent_node._ref_CountDown
	_ref_CreateObject = parent_node._ref_CreateObject
	_ref_Schedule = parent_node._ref_Schedule
	_ref_Palette = parent_node._ref_Palette


# Override.
func take_action() -> void:
	pass


# Override.
func remove_data(_actor: Sprite) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return


func set_local_var(actor: Sprite) -> void:
	var pc = _ref_DungeonBoard.get_pc()

	_self = actor
	_self_pos = Game_ConvertCoord.vector_to_array(_self.position)
	_pc_pos = Game_ConvertCoord.vector_to_array(pc.position)


func _approach_pc(start_point: Array = [_pc_pos], one_step: int = 1,
		opt_passable_arg: Array = []) -> void:
	var destination: Array

	_init_dungeon()
	for i in start_point:
		if _dungeon[i[0]][i[1]] == Game_PathFindingData.UNKNOWN:
			_dungeon[i[0]][i[1]] = Game_PathFindingData.DESTINATION
		else:
			push_warning(INVALID_START_POINT)
			return
	_dungeon = Game_DijkstraPathFinding.get_map(_dungeon, start_point)

	destination = Game_DijkstraPathFinding.get_path(_dungeon,
			_self_pos[0], _self_pos[1], one_step,
			self, "_is_passable_func", opt_passable_arg)

	if destination.size() > 0:
		Game_ArrayHelper.rand_picker(destination, 1, _ref_RandomNumber)
		_ref_DungeonBoard.move_sprite(Game_MainGroupTag.ACTOR,
				_self_pos[0], _self_pos[1],
				destination[0][0], destination[0][1])
		_target_pos = destination[0]


func _init_dungeon() -> void:
	if _dungeon.size() < 1:
		for x in range(Game_DungeonSize.MAX_X):
			_dungeon[x] = []
			_dungeon[x].resize(Game_DungeonSize.MAX_Y)

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_building(x, y):
				_dungeon[x][y] = Game_PathFindingData.OBSTACLE
			else:
				_dungeon[x][y] = Game_PathFindingData.UNKNOWN


func _is_passable_func(source_array: Array, current_index: int,
		_opt_arg: Array) -> bool:
	var x: int = source_array[current_index][0]
	var y: int = source_array[current_index][1]
	return not _ref_DungeonBoard.has_actor(x, y)
