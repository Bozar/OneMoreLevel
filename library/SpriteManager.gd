extends Node2D


var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()

var _current: String = _new_SpriteTypeTag.DEFAULT


func switch_sprite(type_tag: String) -> void:
	if not has_node(type_tag):
		return

	get_node(_current).visible = false
	get_node(type_tag).visible = true
	_current = type_tag
