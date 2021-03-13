extends Node2D
class_name Game_Schedule


signal turn_started(current_sprite)
signal turn_ended(current_sprite)

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _actors: Array = [null]
var _pointer: int = 0
var _end_game: bool = false
var _end_current_turn: bool = true
var _start_first_turn: bool = true


func end_turn() -> void:
	if _end_game:
		return

	if _end_current_turn:
		# print("{0}: End turn.".format([_get_current().name]))
		emit_signal("turn_ended", _get_current())
		_goto_next()
	else:
		_end_current_turn = true

	emit_signal("turn_started", _get_current())


func init_schedule() -> void:
	if _start_first_turn:
		emit_signal("turn_started", _get_current())
		_start_first_turn = false


func _on_CreateObject_sprite_created(new_sprite: Sprite,
		main_group: String, sub_group: String, _x: int, _y: int) -> void:
	if main_group == _new_MainGroupTag.ACTOR:
		if sub_group == _new_SubGroupTag.PC:
			_actors[0] = new_sprite
		else:
			_actors.append(new_sprite)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		_main_group: String, _x: int, _y: int) -> void:
	var current_sprite: Sprite

	if remove_sprite == _get_current():
		_end_current_turn = false
		_goto_next()
	current_sprite = _get_current()

	_actors.erase(remove_sprite)
	_pointer = _actors.find(current_sprite)


func _on_EndGame_game_over(_win: bool) -> void:
	_end_game = true


func _get_current() -> Sprite:
	return _actors[_pointer] as Sprite


func _goto_next() -> void:
	_pointer += 1
	if _pointer > _actors.size() - 1:
		_pointer = 0
