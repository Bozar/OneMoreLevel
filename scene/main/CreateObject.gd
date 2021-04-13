extends Node2D
class_name Game_CreateObject


signal sprite_created(new_sprite, main_group, sub_group, x, y)

var _ref_Palette: Game_Palette

var _new_ZIndex := preload("res://library/ZIndex.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_ScreenTag := preload("res://library/ScreenTag.gd").new()


func create_and_fetch(prefab: PackedScene,
		main_group: String, sub_group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> Sprite:
	var new_sprite: Sprite = prefab.instance() as Sprite
	var sprite_color: String = _ref_Palette.get_default_color(
			main_group, sub_group)
	var z_index: int = _new_ZIndex.get_z_index(main_group)

	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(main_group)
	new_sprite.add_to_group(sub_group)
	new_sprite.z_index = z_index
	new_sprite.modulate = sprite_color

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite, main_group, sub_group, x, y)
	return new_sprite


func create(prefab: PackedScene, main_group: String, sub_group: String,
		x: int, y: int, x_offset: int = 0, y_offset: int = 0) -> void:
	var __ = create_and_fetch(prefab, main_group, sub_group, x, y,
			x_offset, y_offset)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	visible = (screen_tag == _new_ScreenTag.MAIN)
