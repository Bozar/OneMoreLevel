# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn

var _ref_DungeonBoard: DungeonBoard

var _new_InputName := preload("res://library/InputName.gd").new()
var _new_MainGroupName := preload("res://library/MainGroupName.gd").new()

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
	var target: Array = _get_new_position(source, direction)
	var x: int = target[0]
	var y: int = target[1]

	var is_not_ground: bool = \
			(not _ref_DungeonBoard.is_inside_dungeon(x, y)) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupName.BUILDING, x, y) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupName.ACTOR, x, y)

	return not is_not_ground


func is_npc(source: Array, direction: String) -> bool:
	var target: Array = _get_new_position(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupName.ACTOR,
			target[0], target[1])


func is_building(source: Array, direction: String) -> bool:
	var target: Array = _get_new_position(source, direction)

	return _ref_DungeonBoard.has_sprite(_new_MainGroupName.BUILDING,
			target[0], target[1])


func move() -> void:
	pass


func attack() -> void:
	pass


func interact() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_status() -> void:
	end_turn = false


func _get_new_position(source: Array, direction: String) -> Array:
	var shift: Array = _direction_to_coord[direction]

	return [source[0] + shift[0], source[1] + shift[1]]
