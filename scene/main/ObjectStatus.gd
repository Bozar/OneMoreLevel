extends Node2D


var _new_SpriteStatusTag := preload("res://library/SpriteStatusTag.gd").new()

var _id_to_status: Dictionary = {}


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	_id_to_status[new_sprite.get_instance_id()] = _new_SpriteStatusTag.DEFAULT


func get_status(sprite: Sprite) -> String:
	return _id_to_status[_get_id(sprite)]


func set_status(sprite: Sprite, status: String) -> void:
	_id_to_status[_get_id(sprite)] = status


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
