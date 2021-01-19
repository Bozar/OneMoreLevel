extends Node2D
class_name Game_InitWorld
# Blueprints are scattered in three scripts.
# * Floors are created in WorldTemplate.gd.
# * Arrow indicators are created in this script.
# * Everything else are created by calling _world.get_blueprint().


signal world_selected(new_world)

var _spr_TriangleRight := preload("res://sprite/TriangleRight.tscn")
var _spr_TriangleDown := preload("res://sprite/TriangleDown.tscn")
var _spr_TriangleUp := preload("res://sprite/TriangleUp.tscn")

var _ref_RandomNumber: Game_RandomNumber
var _ref_CreateObject: Game_CreateObject
var _ref_GameSetting : Game_GameSetting
var _ref_DangerZone: Game_DangerZone
var _ref_Schedule: Game_Schedule

var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_InitWorldData := preload("res://library/InitWorldData.gd").new()
var _new_ArrayHelper := preload("res://library/ArrayHelper.gd").new()

var _world_template: Game_WorldTemplate


# func _unhandled_input(event: InputEvent) -> void:
# 	if event.is_action_pressed(_new_InputTag.INIT_WORLD):
# 		init_world()
#
# 		set_process_unhandled_input(false)


func init_world() -> void:
	_ref_GameSetting.load_setting()
	_world_template = _get_world()

	# sb: SpriteBlueprint
	for sb in _world_template.get_blueprint():
		if _is_pc(sb.sub_group):
			_init_indicator(sb.x, sb.y)
		_ref_CreateObject.create(
				sb.scene, sb.main_group, sb.sub_group, sb.x, sb.y)
	_ref_Schedule.init_schedule()


func _get_world() -> Game_WorldTemplate:
	var full_tag: Array = _new_WorldTag.get_full_world_tag()
	var exclude_world: Array = _ref_GameSetting.get_exclude_world()
	var world_tag: String = _ref_GameSetting.get_world_tag()

	_new_ArrayHelper.filter_element(full_tag, self, "_filter_get_world",
			[exclude_world])
	if full_tag.size() == 0:
		full_tag = [_new_WorldTag.DEMO]
	_new_ArrayHelper.random_picker(full_tag, 1, _ref_RandomNumber)

	if world_tag == "":
		world_tag = full_tag[0]
	emit_signal("world_selected", world_tag)

	return _new_InitWorldData.get_world_template(world_tag).new(self)


func _init_indicator(x: int, y: int) -> void:
	_ref_CreateObject.create(_spr_TriangleRight,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_RIGHT,
			0, y, -_new_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_TriangleDown,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_DOWN,
			x, 0, 0, -_new_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_TriangleUp,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_UP,
			x, _new_DungeonSize.MAX_Y - 1, 0, _new_DungeonSize.ARROW_MARGIN)


func _is_pc(group_name: String) -> bool:
	return group_name == _new_SubGroupTag.PC


func _filter_get_world(source: Array, index: int, opt_arg: Array) -> bool:
	var exclude: Array = opt_arg[0]
	return not source[index] in exclude
