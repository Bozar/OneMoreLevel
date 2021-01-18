extends Node2D
class_name Game_InitWorld
# Blueprints are scattered in three scripts.
# * Floors are created in WorldTemplate.gd.
# * Arrow indicators are created in this script.
# * Everything else are created by calling _world.get_blueprint().


signal world_selected(new_world)

var _spr_ArrowLeft := preload("res://sprite/ArrowLeft.tscn")
var _spr_ArrowTop := preload("res://sprite/ArrowTop.tscn")
var _spr_ArrowBottom := preload("res://sprite/ArrowBottom.tscn")

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
	var tag_index: int = _ref_RandomNumber.get_int(0, full_tag.size())
	var world_tag: String = _ref_GameSetting.get_world_tag()
	var world_template: Game_WorldTemplate

	if world_tag == "":
		world_tag = full_tag[tag_index]
	emit_signal("world_selected", world_tag)

	world_template = _new_InitWorldData.get_world_template(world_tag).new(self)
	return world_template


func _init_indicator(x: int, y: int) -> void:
	_ref_CreateObject.create(_spr_ArrowLeft,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_LEFT,
			0, y, -_new_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_ArrowTop,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_TOP,
			x, 0, 0, -_new_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_ArrowBottom,
			_new_MainGroupTag.INDICATOR, _new_SubGroupTag.ARROW_BOTTOM,
			x, _new_DungeonSize.MAX_Y - 1, 0, _new_DungeonSize.ARROW_MARGIN)


func _is_pc(group_name: String) -> bool:
	return group_name == _new_SubGroupTag.PC
