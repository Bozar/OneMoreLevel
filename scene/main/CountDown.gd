extends Node2D
class_name Game_CountDown


const MAX_TURN: int = 24
const MIN_TURN: int = 1
const ONE_TURN: int = 1
const ZERO_TURN: int = 0

var _ref_EndGame: Game_EndGame

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _current_count: int = MAX_TURN


func get_count(fix_overflow: bool) -> int:
	if fix_overflow:
		return _fix_overflow()
	return _current_count


func add_count(add: int) -> void:
	_current_count += add


func subtract_count(subtract: int) -> void:
	_current_count -= subtract


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return
	_current_count = _fix_overflow()


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		subtract_count(ONE_TURN)
	if _current_count < MIN_TURN:
		_current_count = _fix_overflow()
		_ref_EndGame.player_lose()


func _fix_overflow() -> int:
	if _current_count > MAX_TURN:
		_current_count = MAX_TURN
	elif _current_count < MIN_TURN:
		_current_count = ZERO_TURN
	return _current_count
