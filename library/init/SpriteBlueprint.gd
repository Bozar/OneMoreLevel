class_name Game_SpriteBlueprint


var scene: PackedScene setget set_scene, get_scene
var main_tag: String setget set_main_tag, get_main_tag
var sub_tag: String setget set_sub_tag, get_sub_tag
var x: int setget set_x, get_x
var y: int setget set_y, get_y


func _init(_scene: PackedScene, _main_tag: String, _sub_tag: String,
		_x: int, _y: int) -> void:
	scene = _scene
	main_tag = _main_tag
	sub_tag = _sub_tag
	x = _x
	y = _y


func get_scene() -> PackedScene:
	return scene


func set_scene(_scene: PackedScene) -> void:
	return


func get_main_tag() -> String:
	return main_tag


func set_main_tag(_main_tag: String) -> void:
	return


func get_sub_tag() -> String:
	return sub_tag


func set_sub_tag(_sub_tag: String) -> void:
	return


func get_x() -> int:
	return x


func set_x(_x: int) -> void:
	return


func get_y() -> int:
	return y


func set_y(_y: int) -> void:
	return
