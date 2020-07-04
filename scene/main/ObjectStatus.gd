extends Node2D


var _new_ObjectStatusTag := preload("res://library/ObjectStatusTag.gd").new()

var _id_to_status: Dictionary = {}


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	_id_to_status[new_sprite.get_instance_id()] = _new_ObjectStatusTag.DEFAULT


func get_status(sprite: Sprite) -> String:
	return _id_to_status[_get_id(sprite)]


func set_status(sprite: Sprite, status: String) -> void:
	_id_to_status[_get_id(sprite)] = status


func verify_status(sprite: Sprite, status: String) -> bool:
	return _id_to_status[_get_id(sprite)] == status


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
