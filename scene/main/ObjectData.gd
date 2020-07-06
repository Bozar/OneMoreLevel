extends Node2D


const OBJECT_STATUS: String = "ObjectStatus"
const SPRITE_TYPE: String = "SpriteType"

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_ObjectStatusTag := preload("res://library/ObjectStatusTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		return

	var id: int = _get_id(new_sprite)

	get_node(OBJECT_STATUS).set_status(id, _new_ObjectStatusTag.DEFAULT)
	get_node(SPRITE_TYPE).set_sprite_type(id, _new_SpriteTypeTag.DEFAULT)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		_main_group: String, _x: int, _y: int) -> void:
	var id: int = _get_id(remove_sprite)

	get_node(OBJECT_STATUS).remove_data(id)
	get_node(SPRITE_TYPE).remove_data(id)


func get_status(sprite: Sprite) -> String:
	return get_node(OBJECT_STATUS).get_status(_get_id(sprite))


func set_status(sprite: Sprite, status: String) -> void:
	get_node(OBJECT_STATUS).set_status(_get_id(sprite), status)


func verify_status(sprite: Sprite, status: String) -> bool:
	return get_node(OBJECT_STATUS).verify_status(_get_id(sprite), status)


func get_sprite_type(sprite: Sprite) -> String:
	return get_node(SPRITE_TYPE).get_sprite_type(_get_id(sprite))


func set_sprite_type(sprite: Sprite, sprite_type: String) -> void:
	get_node(SPRITE_TYPE).set_sprite_type(_get_id(sprite), sprite_type)


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
