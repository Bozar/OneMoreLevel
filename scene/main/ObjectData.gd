extends Node2D


const OBJECT_STATE: String = "ObjectState"
const SPRITE_TYPE: String = "SpriteType"
const HIT_POINT: String = "HitPoint"

var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()

var _child_node: Array = [
	OBJECT_STATE, SPRITE_TYPE, HIT_POINT,
]


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_MainGroupTag.INDICATOR):
		return

	var id: int = _get_id(new_sprite)

	get_node(OBJECT_STATE).set_state(id, _new_ObjectStateTag.DEFAULT)
	get_node(SPRITE_TYPE).set_sprite_type(id, _new_SpriteTypeTag.DEFAULT)
	get_node(HIT_POINT).set_hit_point(id, 0)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite,
		_main_group: String, _x: int, _y: int) -> void:
	for cn in _child_node:
		get_node(cn).remove_data(_get_id(remove_sprite))


func get_state(sprite: Sprite) -> String:
	return get_node(OBJECT_STATE).get_state(_get_id(sprite))


func set_state(sprite: Sprite, State: String) -> void:
	get_node(OBJECT_STATE).set_state(_get_id(sprite), State)


func verify_state(sprite: Sprite, State: String) -> bool:
	return get_node(OBJECT_STATE).verify_state(_get_id(sprite), State)


func get_sprite_type(sprite: Sprite) -> String:
	return get_node(SPRITE_TYPE).get_sprite_type(_get_id(sprite))


func set_sprite_type(sprite: Sprite, sprite_type: String) -> void:
	get_node(SPRITE_TYPE).set_sprite_type(_get_id(sprite), sprite_type)


func get_hit_point(sprite: Sprite) -> int:
	return get_node(HIT_POINT).get_hit_point(_get_id(sprite))


func set_hit_point(sprite: Sprite, hit_point: int) -> void:
	get_node(HIT_POINT).set_hit_point(_get_id(sprite), hit_point)


func add_hit_point(sprite: Sprite, hit_point: int) -> void:
	get_node(HIT_POINT).add_hit_point(_get_id(sprite), hit_point)


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
