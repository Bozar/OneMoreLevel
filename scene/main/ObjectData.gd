extends Node2D


const OBJECT_STATUS: String = "ObjectStatus"

var _new_ObjectStatusTag := preload("res://library/ObjectStatusTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		return

	var id: int = _get_id(new_sprite)

	get_node(OBJECT_STATUS).set_status(id, _new_ObjectStatusTag.DEFAULT)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		_main_group: String, _x: int, _y: int) -> void:
	var id: int = _get_id(remove_sprite)

	get_node(OBJECT_STATUS).remove_data(id)


func get_status(sprite: Sprite) -> String:
	return get_node(OBJECT_STATUS).get_status(_get_id(sprite))


func set_status(sprite: Sprite, status: String) -> void:
	get_node(OBJECT_STATUS).set_status(_get_id(sprite), status)


func verify_status(sprite: Sprite, status: String) -> bool:
	return get_node(OBJECT_STATUS).verify_status(_get_id(sprite), status)


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
