extends Node2D
class_name Game_CountDown


var _ref_EndGame: Game_EndGame

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_CountDownData := preload("res://library/CountDownData.gd").new()

var _current_count: int = _new_CountDownData.MAX_COUNT


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
	if _current_count < _new_CountDownData.MIN_COUNT:
		_ref_EndGame.player_lose()


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		subtract_count(1)


func _fix_overflow() -> int:
	var fix: int = _current_count

	fix = min(fix, _new_CountDownData.MAX_COUNT) as int
	fix = max(fix, _new_CountDownData.ZERO) as int

	return fix
