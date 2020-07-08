extends Node2D


var _id_to_hit_point: Dictionary = {}
var _invalid_hit_point: int = -999


func get_hit_point(id: int) -> int:
	if _id_to_hit_point.has(id):
		return _id_to_hit_point[id]
	return _invalid_hit_point


func set_hit_point(id: int, hit_point: int) -> void:
	_id_to_hit_point[id] = hit_point


func add_hit_point(id: int, hit_point: int) -> void:
	if _id_to_hit_point.has(id):
		_id_to_hit_point[id] += hit_point


func remove_data(id: int) -> void:
	var __ = _id_to_hit_point.erase(id)
