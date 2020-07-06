extends Node2D


var _id_to_sprite_type: Dictionary = {}


func get_sprite_type(id: int) -> String:
	if _id_to_sprite_type.has(id):
		return _id_to_sprite_type[id]
	return ""


func set_sprite_type(id: int, sprite_type: String) -> void:
	_id_to_sprite_type[id] = sprite_type


func remove_data(id: int) -> void:
	var __ = _id_to_sprite_type.erase(id)
