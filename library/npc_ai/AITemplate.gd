class_name Game_AITemplate


const INVALID_START_POINT: String = "Unreachable start point."

var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: Game_ObjectData
var _ref_DungeonBoard: Game_DungeonBoard
var _ref_SwitchSprite: Game_SwitchSprite
var _ref_DangerZone: Game_DangerZone
var _ref_EndGame: Game_EndGame
var _ref_RandomNumber: Game_RandomNumber
var _ref_RemoveObject: Game_RemoveObject
var _ref_CountDown: Game_CountDown
var _ref_CreateObject: Game_CreateObject
var _ref_Schedule: Game_Schedule
var _ref_Palette: Game_Palette

var _self: Sprite
var _pc_pos: Game_IntCoord
var _self_pos: Game_IntCoord
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
	_self = actor
	_self_pos = Game_ConvertCoord.sprite_to_coord(_self)
	_pc_pos = _ref_DungeonBoard.get_pc_coord()


func _approach_pc(start_point := [_pc_pos], step_length := 1, step_count := 1,
		opt_passable_arg := []) -> void:
	var destination: Array

	Game_DungeonSize.init_dungeon_grids_by_func(_dungeon, self,
			"_get_init_value", [], false)
	for i in start_point:
		if _dungeon[i.x][i.y] == Game_PathFindingData.UNKNOWN:
			_dungeon[i.x][i.y] = Game_PathFindingData.DESTINATION
		else:
			push_warning(INVALID_START_POINT)
			return
	_dungeon = Game_DijkstraPathFinding.get_map(_dungeon, start_point)

	for i in range(0, step_count):
		if (i > 0) and _stop_move():
			break
		destination = Game_DijkstraPathFinding.get_path(_dungeon,
				_self_pos.x, _self_pos.y, step_length,
				self, "_is_passable_func", opt_passable_arg)

		if destination.size() > 0:
			Game_ArrayHelper.rand_picker(destination, 1, _ref_RandomNumber)
			_ref_DungeonBoard.move_actor_xy(_self_pos.x, _self_pos.y,
					destination[0].x, destination[0].y)
			_self_pos = destination[0]


func _get_init_value(x: int, y: int, _opt_arg: Array) -> int:
	if _is_obstacle(x, y):
		return Game_PathFindingData.OBSTACLE
	else:
		return Game_PathFindingData.UNKNOWN


func _is_obstacle(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_building_xy(x, y)


func _is_passable_func(source_array: Array, current_index: int,
		_opt_arg: Array) -> bool:
	var x: int = source_array[current_index].x
	var y: int = source_array[current_index].y
	return not _ref_DungeonBoard.has_actor_xy(x, y)


func _stop_move() -> bool:
	return false
