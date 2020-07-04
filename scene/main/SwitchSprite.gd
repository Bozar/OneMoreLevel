extends Node2D


var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()

var _id_to_type: Dictionary = {}


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	_id_to_type[new_sprite.get_instance_id()] = _new_SpriteTypeTag.DEFAULT


func switch_sprite(sprite: Sprite, type_tag: String) -> void:
	if not sprite.has_node(type_tag):
		return

	var id: int = sprite.get_instance_id()
	var current_type: String = _id_to_type[id]

	sprite.get_node(current_type).visible = false
	sprite.get_node(type_tag).visible = true

	current_type = type_tag
	_id_to_type[id] = current_type
