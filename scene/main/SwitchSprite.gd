extends Node2D


const ObjectData := preload("res://scene/main/ObjectData.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")

var _ref_ObjectData: ObjectData
var _ref_DungeonBoard: DungeonBoard


func switch_sprite(sprite: Sprite, type_tag: String,
		new_color: String = "") -> void:
	var current_type: String

	if not sprite.has_node(type_tag):
		return

	current_type = _ref_ObjectData.get_sprite_type(sprite)

	sprite.get_node(current_type).visible = false
	sprite.get_node(type_tag).visible = true
	_change_color(sprite, new_color)

	current_type = type_tag
	_ref_ObjectData.set_sprite_type(sprite, current_type)


func switch_sprite_by_position(main_tag: String, x: int, y: int,
		type_tag: String, new_color: String = "") -> void:
	var sprite: Sprite = _ref_DungeonBoard.get_sprite(main_tag, x, y)

	if sprite == null:
		return
	switch_sprite(sprite, type_tag, new_color)


func _change_color(sprite: Sprite, new_color: String) -> void:
	if new_color == "":
		return
	sprite.modulate = new_color
