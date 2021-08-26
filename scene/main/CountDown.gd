extends Node2D
class_name Game_CountDown


const MAX_TURN := 24
const MIN_TURN := 1
const ONE_TURN := 1
const ZERO_TURN := 0

var _ref_EndGame: Game_EndGame

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
	if not current_sprite.is_in_group(Game_SubTag.PC):
		return
	_current_count = _fix_overflow()


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(Game_SubTag.PC):
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
