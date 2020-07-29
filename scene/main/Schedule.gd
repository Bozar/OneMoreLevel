extends Node2D
class_name Game_Schedule


signal turn_started(current_sprite)
signal turn_ended(current_sprite)

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _actors: Array = [null]
var _pointer: int = 0
var _end_game: bool = false


func end_turn() -> void:
	# print("{0}: End turn.".format([_get_current().name]))
	emit_signal("turn_ended", _get_current())

	if _end_game:
		return

	_goto_next()
	emit_signal("turn_started", _get_current())


func count_npc() -> int:
	return _actors.size() - 1


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_MainGroupTag.ACTOR):
		if new_sprite.is_in_group(_new_SubGroupTag.PC):
			_actors[0] = new_sprite
		else:
			_actors.append(new_sprite)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
	_main_group: String, _x: int, _y: int) -> void:

	var current_sprite: Sprite = _get_current()

	_actors.erase(remove_sprite)
	_pointer = _actors.find(current_sprite)


func _on_EndGame_game_is_over(_win: bool) -> void:
	_end_game = true


func _get_current() -> Sprite:
	return _actors[_pointer] as Sprite


func _goto_next() -> void:
	_pointer += 1

	if _pointer > len(_actors) - 1:
		_pointer = 0
