extends Node2D
class_name Game_HitPoint


var _id_to_hit_point: Dictionary = {}


func get_hit_point(id: int) -> int:
	if not _id_to_hit_point.has(id):
		_id_to_hit_point[id] = 0
	return _id_to_hit_point[id]


func set_hit_point(id: int, hit_point: int) -> void:
	_id_to_hit_point[id] = hit_point


func add_hit_point(id: int, hit_point: int) -> void:
	if _id_to_hit_point.has(id):
		_id_to_hit_point[id] += hit_point
	else:
		_id_to_hit_point[id] = hit_point


func subtract_hit_point(id: int, hit_point: int) -> void:
	add_hit_point(id, -hit_point)


func remove_data(id: int) -> void:
	var __ = _id_to_hit_point.erase(id)
