extends Node2D
class_name Game_ObjectData


const OBJECT_STATE := "ObjectState"
const OBJECT_LAYER := "ObjectLayer"
const BOOL_STATE := "BoolState"
const SPRITE_TYPE := "SpriteType"
const HIT_POINT := "HitPoint"


func _on_CreateObject_sprite_created(new_sprite: Sprite, _main_tag: String,
		_sub_tag: String, _x: int, _y: int, layer: int) -> void:
	if layer != 0:
		set_layer(new_sprite, layer)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite, _main_tag: String,
		_x: int, _y: int, _sprite_layer: int) -> void:
	var child_node: Array = get_children()
	for i in child_node:
		i.remove_data(_get_id(remove_sprite))


func get_state(sprite: Sprite) -> int:
	return get_node(OBJECT_STATE).get_state(_get_id(sprite))


func set_state(sprite: Sprite, state: int) -> void:
	get_node(OBJECT_STATE).set_state(_get_id(sprite), state)


func verify_state(sprite: Sprite, state: int) -> bool:
	return get_node(OBJECT_STATE).verify_state(_get_id(sprite), state)


func get_layer(sprite: Sprite) -> int:
	return get_node(OBJECT_LAYER).get_layer(_get_id(sprite))


func set_layer(sprite: Sprite, layer: int) -> void:
	get_node(OBJECT_LAYER).set_layer(_get_id(sprite), layer)


func get_bool(sprite: Sprite) -> bool:
	return get_node(BOOL_STATE).get_bool(_get_id(sprite))


func set_bool(sprite: Sprite, state: bool) -> void:
	get_node(BOOL_STATE).set_bool(_get_id(sprite), state)


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


func subtract_hit_point(sprite: Sprite, hit_point: int) -> void:
	get_node(HIT_POINT).subtract_hit_point(_get_id(sprite), hit_point)


func _get_id(sprite: Sprite) -> int:
	return sprite.get_instance_id()
