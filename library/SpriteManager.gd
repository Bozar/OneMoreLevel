extends Node2D


var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd")

var _current: String = _new_SpriteTypeTag.DEFAULT


func switch_sprite(type_tag: String) -> void:
	if not has_node(type_tag):
		return

	get_node(_current).visible = false
	get_node(type_tag).visible = true
	_current = type_tag


# NOTE: Reset color if the sprite is removed from scene and will be recycled
# later.
func set_color(new_color: String) -> void:
	modulate = new_color
