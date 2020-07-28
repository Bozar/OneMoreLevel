extends Node2D
class_name Game_CountDown


const _hit_bonus: int = 5
const _max_count: int = 24

var _ref_EndGame: Game_EndGame

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()

var _current_count: int = _max_count


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return
	if _current_count < 1:
		_ref_EndGame.player_lose()


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		subtract_count(1)


func get_count() -> int:
	return _current_count


func hit_bonus() -> void:
	add_count(_hit_bonus)


func add_count(add: int) -> void:
	_current_count += add

	if _current_count > _max_count:
		_current_count = _max_count


func subtract_count(subtract: int) -> void:
	_current_count -= subtract
