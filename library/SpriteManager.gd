extends Node2D
# This script is attached to sprites directly. Consider replacing it with a
# scene in the future if necessary.


var sprite_status: String  setget set_status, get_status

var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_SpriteStatusTag := preload("res://library/SpriteStatusTag.gd").new()

var _current_type: String


func _ready() -> void:
	sprite_status = _new_SpriteStatusTag.DEFAULT
	_current_type = _new_SpriteTypeTag.DEFAULT


func switch_sprite(type_tag: String) -> void:
	if not has_node(type_tag):
		return

	get_node(_current_type).visible = false
	get_node(type_tag).visible = true
	_current_type = type_tag


func get_status() -> String:
	return sprite_status


func set_status(status: String) -> void:
	sprite_status = status
