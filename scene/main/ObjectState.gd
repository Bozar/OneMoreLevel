extends Node2D
class_name Game_ObjectState


var _id_to_state: Dictionary = {}


func get_state(id: int) -> int:
	if not _id_to_state.has(id):
		_id_to_state[id] = Game_StateTag.DEFAULT
	return _id_to_state[id]


func set_state(id: int, state: int) -> void:
	_id_to_state[id] = state


func verify_state(id: int, state: int) -> bool:
	if _id_to_state.has(id):
		return _id_to_state[id] == state
	return state == Game_StateTag.DEFAULT


func remove_data(id: int) -> void:
	var __ = _id_to_state.erase(id)
