extends Node2D
class_name Game_SpriteType


var _id_to_sprite_type: Dictionary = {}


func get_sprite_type(id: int) -> String:
	if not _id_to_sprite_type.has(id):
		_id_to_sprite_type[id] = Game_SpriteTypeTag.DEFAULT
	return _id_to_sprite_type[id]


func set_sprite_type(id: int, sprite_type: String) -> void:
	_id_to_sprite_type[id] = sprite_type


func remove_data(id: int) -> void:
	var __ = _id_to_sprite_type.erase(id)
