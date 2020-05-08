extends Node2D
# Blueprints are scattered in three scripts.
# * Floors are created in WorldTemplate.gd.
# * Arrow indicators are created in this script.
# * Everything else are created by calling _world.get_blueprint().


signal sprite_created(new_sprite)

const ArrowX := preload("res://sprite/ArrowX.tscn")
const ArrowY := preload("res://sprite/ArrowY.tscn")
const RandomNumber := preload("res://scene/main/RandomNumber.gd")

const WorldTemplate := preload("res://library/init/WorldTemplate.gd")
const InitDemo := preload("res://library/init/InitDemo.gd")

var _ref_RandomNumber: RandomNumber

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupName := preload("res://library/MainGroupName.gd").new()
var _new_SubGroupName := preload("res://library/SubGroupName.gd").new()
var _new_InputName := preload("res://library/InputName.gd").new()

var _world: WorldTemplate


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputName.INIT_WORLD):
		_world = _select_world()
		# sb: SpriteBlueprint
		for sb in _world.get_blueprint():
			if _is_pc(sb.sub_group):
				_init_indicator(sb.x, sb.y)
			_create_sprite(sb.scene, sb.main_group, sb.sub_group, sb.x, sb.y)

		set_process_unhandled_input(false)


func _select_world() -> WorldTemplate:
	var candidate
	candidate = InitDemo.new(_ref_RandomNumber)
	return candidate


func _init_indicator(x: int, y: int) -> void:
	_create_sprite(ArrowX,
			_new_MainGroupName.INDICATOR, _new_SubGroupName.ARROW,
			0, y, -_new_DungeonSize.ARROW_MARGIN)
	_create_sprite(ArrowY,
			_new_MainGroupName.INDICATOR, _new_SubGroupName.ARROW,
			x, 0, 0, -_new_DungeonSize.ARROW_MARGIN)


func _create_sprite(prefab: PackedScene, main_group: String, sub_group: String,
		x: int, y: int, x_offset: int = 0, y_offset: int = 0) -> void:

	var new_sprite: Sprite = prefab.instance() as Sprite
	new_sprite.position = _new_ConvertCoord.index_to_vector(
			x, y, x_offset, y_offset)
	new_sprite.add_to_group(main_group)
	new_sprite.add_to_group(sub_group)

	add_child(new_sprite)
	emit_signal("sprite_created", new_sprite)


func _is_pc(group_name: String) -> bool:
	return group_name == _new_SubGroupName.PC
