class_name Game_SpriteBlueprint


var scene: PackedScene setget set_scene, get_scene
var main_group: String setget set_main_group, get_main_group
var sub_group: String setget set_sub_group, get_sub_group
var x: int setget set_x, get_x
var y: int setget set_y, get_y


func _init(set_scene: PackedScene, set_main: String, set_sub: String,
		set_x: int, set_y: int) -> void:
	scene = set_scene
	main_group = set_main
	sub_group = set_sub
	x = set_x
	y = set_y


func get_scene() -> PackedScene:
	return scene


func set_scene(_scene: PackedScene) -> void:
	return


func get_main_group() -> String:
	return main_group


func set_main_group(_main_group: String) -> void:
	return


func get_sub_group() -> String:
	return sub_group


func set_sub_group(_sub_group: String) -> void:
	return


func get_x() -> int:
	return x


func set_x(_x: int) -> void:
	return


func get_y() -> int:
	return y


func set_y(_y: int) -> void:
	return
