extends Node2D


const Player := preload("res://sprite/PC.tscn")
const Wall := preload("res://sprite/Wall.tscn")

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()


func get_blueprint() -> Array:
	# [[PackedScene, group_name, x, y], ...]
	var sprite_template: Array = []

	_init_wall(sprite_template)
	_init_PC(sprite_template)

	return sprite_template


func _init_wall(template: Array) -> void:
	var shift: int = 2
	var min_x: int = _new_DungeonSize.CENTER_X - shift
	var max_x: int = _new_DungeonSize.CENTER_X + shift + 1
	var min_y: int = _new_DungeonSize.CENTER_Y - shift
	var max_y: int = _new_DungeonSize.CENTER_Y + shift + 1

	for i in range(min_x, max_x):
		for j in range(min_y, max_y):
			template.push_back([Wall, _new_GroupName.WALL, i, j])


func _init_PC(template: Array) -> void:
	template.push_back([Player, _new_GroupName.PC, 0, 0])
