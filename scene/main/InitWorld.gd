extends Node2D


signal sprite_created(new_sprite)

const Floor := preload("res://sprite/Floor.tscn")
const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")

const InitDemo := preload("res://library/init/InitDemo.gd")

var _ref_RandomNumber: RandomNumber

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_GroupName := preload("res://library/GroupName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()

var _world: GDScript


func _ready() -> void:
	_world = _select_world()


func _unhandled_input(event: InputEvent) -> void:
	var scene: PackedScene
	var group_name: String
	var x: int
	var y: int

	if event.is_action_pressed(_new_InputName.INIT_WORLD):
		_init_floor()

		_world.init_self(_ref_RandomNumber)
		# [[PackedScene, group_name, x, y], ...]
		for i in _world.get_blueprint():
			scene = i[0]
			group_name = i[1]
			x = i[2]
			y = i[3]

			if _is_pc(group_name):
				_init_indicator(x, y)
			_create_sprite(scene, group_name, x, y)

		set_process_unhandled_input(false)


func _select_world() -> GDScript:
	var candidate
	candidate = InitDemo.new()
	return candidate


func _init_floor() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			_create_sprite(Floor, _new_GroupName.FLOOR, i, j)


func _init_indicator(x: int, y: int) -> void:
	_create_sprite(ArrowX, _new_GroupName.ARROW, 0, y,
			-_new_DungeonSize.ARROW_MARGIN)
	_create_sprite(ArrowY, _new_GroupName.ARROW, x, 0,
			0, -_new_DungeonSize.ARROW_MARGIN)


func _create_sprite(prefab: PackedScene, group: String, x: int, y: int,
		x_offset: int = 0, y_offset: int = 0) -> void:

	var new_sprite: Sprite = prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(group)

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite)


func _is_pc(group_name: String) -> bool:
	return group_name == _new_GroupName.PC
