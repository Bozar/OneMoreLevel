extends Node2D


var _id_to_status: Dictionary = {}


func get_status(id: int) -> String:
	if _id_to_status.has(id):
		return _id_to_status[id]
	return "ERROR: ID not found."


func set_status(id: int, status: String) -> void:
	_id_to_status[id] = status


func verify_status(id: int, status: String) -> bool:
	if _id_to_status.has(id):
		return _id_to_status[id] == status
	return false
