# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn

var _ref_DungeonBoard: DungeonBoard

var _new_InputName := preload("res://library/InputName.gd").new()
var _new_MainGroupName := preload("res://library/MainGroupName.gd").new()

var _source_position: Array
var _target_position: Array
var _direction_to_coord: Dictionary = {
	_new_InputName.MOVE_UP: [0, -1],
	_new_InputName.MOVE_DOWN: [0, 1],
	_new_InputName.MOVE_LEFT: [-1, 0],
	_new_InputName.MOVE_RIGHT: [1, 0],
}


func _init(dungeon: DungeonBoard) -> void:
	_ref_DungeonBoard = dungeon


func get_message() -> String:
	return message


func set_message(_message: String) -> void:
	pass


func get_end_turn() -> bool:
	return end_turn


func set_end_turn(_end_turn: bool) -> void:
	pass


func is_ground(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	var x: int = _target_position[0]
	var y: int = _target_position[1]

	var is_not_ground: bool = \
			(not _ref_DungeonBoard.is_inside_dungeon(x, y)) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupName.BUILDING, x, y) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupName.ACTOR, x, y)

	return not is_not_ground


func is_npc(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupName.ACTOR,
			_target_position[0], _target_position[1])


func is_building(source: Array, direction: String) -> bool:
	_set_source_target_positions(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupName.BUILDING,
			_target_position[0], _target_position[1])


func move() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupName.ACTOR,
			_source_position, _target_position)

	end_turn = true


func attack() -> void:
	pass


func interact() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_status() -> void:
	end_turn = false


func _set_source_target_positions(source: Array, direction: String) -> void:
	var shift: Array = _direction_to_coord[direction]

	_source_position = source
	_target_position = [source[0] + shift[0], source[1] + shift[1]]
