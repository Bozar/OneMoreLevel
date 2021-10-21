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
var _ref_GameSetting: Game_GameSetting
var _ref_DangerZone: Game_DangerZone
var _ref_Schedule: Game_Schedule

var _world_tag: String
var _world_template: Game_WorldTemplate

# func _unhandled_input(event: InputEvent) -> void:
# 	if event.is_action_pressed(Game_InputTag.INIT_WORLD):
# 		init_world()
#
# 		set_process_unhandled_input(false)


func init_world() -> void:
	_ref_GameSetting.load_setting()
	_world_template = _get_world()

	# sb: SpriteBlueprint
	for sb in _world_template.get_blueprint():
		if _is_pc(sb.sub_tag):
			_init_indicator(sb.x, sb.y)
		_ref_CreateObject.create(sb.scene, sb.main_tag, sb.sub_tag, sb.x, sb.y)
	_ref_Schedule.init_schedule()
	_world_template.clear_blueprint()


func _on_GameSetting_setting_saved(save_data: Game_TransferData,
		_save_tag: int) -> void:
	save_data.world_tag = _world_tag


func _get_world() -> Game_WorldTemplate:
	var full_tag: Array = Game_WorldTag.get_full_world_tag()
	var include_world: Array = _ref_GameSetting.get_include_world()
	var exclude_world: Array = _ref_GameSetting.get_exclude_world()

	for i in [include_world, exclude_world]:
		Game_ArrayHelper.filter_element(i, self, "_verify_world_tag", [])
	if include_world.size() > 0:
		Game_ArrayHelper.rand_picker(include_world, 1, _ref_RandomNumber)
		_world_tag = include_world[0]
	else:
		Game_ArrayHelper.filter_element(full_tag, self, "_filter_get_world",
				[exclude_world])
		if full_tag.size() == 0:
			full_tag = [Game_WorldTag.DEMO]
		Game_ArrayHelper.rand_picker(full_tag, 1, _ref_RandomNumber)
		_world_tag = full_tag[0]
	emit_signal("world_selected", _world_tag)

	return Game_InitWorldData.get_world_template(_world_tag).new(self)


func _init_indicator(x: int, y: int) -> void:
	_ref_CreateObject.create(_spr_TriangleRight,
			Game_MainTag.INDICATOR, Game_SubTag.ARROW_RIGHT,
			0, y, -Game_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_TriangleDown,
			Game_MainTag.INDICATOR, Game_SubTag.ARROW_DOWN,
			x, 0, 0, -Game_DungeonSize.ARROW_MARGIN)

	_ref_CreateObject.create(_spr_TriangleUp,
			Game_MainTag.INDICATOR, Game_SubTag.ARROW_UP,
			x, Game_DungeonSize.MAX_Y - 1, 0, Game_DungeonSize.ARROW_MARGIN)


func _is_pc(group_name: String) -> bool:
	return group_name == Game_SubTag.PC


func _filter_get_world(source: Array, index: int, opt_arg: Array) -> bool:
	var exclude: Array = opt_arg[0]
	return not source[index] in exclude


func _verify_world_tag(source: Array, index: int, _opt_arg: Array) -> bool:
	if source[index] is String:
		source[index] = source[index].to_lower()
		if Game_WorldTag.is_valid_world_tag(source[index]):
			return true
	return false
