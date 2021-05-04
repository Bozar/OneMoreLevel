extends Node2D
class_name Game_BoolState


var _id_to_bool: Dictionary = {}


func get_bool(id: int) -> bool:
	if not _id_to_bool.has(id):
		_id_to_bool[id] = false
	return _id_to_bool[id]


func set_bool(id: int, state: bool) -> void:
	_id_to_bool[id] = state


func remove_data(id: int) -> void:
	var __ = _id_to_bool.erase(id)
