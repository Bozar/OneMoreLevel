extends Node2D


var _id_to_state: Dictionary = {}


func get_state(id: int) -> String:
	if _id_to_state.has(id):
		return _id_to_state[id]
	return ""


func set_state(id: int, state: String) -> void:
	_id_to_state[id] = state


func verify_state(id: int, state: String) -> bool:
	if _id_to_state.has(id):
		return _id_to_state[id] == state
	return false


func remove_data(id: int) -> void:
	var __ = _id_to_state.erase(id)
