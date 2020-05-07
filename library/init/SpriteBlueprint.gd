var scene: PackedScene setget ,get_scene
var main_group: String setget ,get_main_group
var sub_group: String setget ,get_sub_group
var x: int setget ,get_x
var y: int setget ,get_y


func _init(set_scene: PackedScene, set_main: String, set_sub: String,
		set_x: int, set_y: int) -> void:

	scene = set_scene
	main_group = set_main
	sub_group = set_sub
	x = set_x
	y = set_y


func get_scene() -> PackedScene:
	return scene


func get_main_group() -> String:
	return main_group


func get_sub_group() -> String:
	return sub_group


func get_x() -> int:
	return x


func get_y() -> int:
	return y
