extends Game_PCActionTemplate


var _is_time_stop: bool = false
var _count_time_stop: int


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func switch_sprite() -> void:
	pass


func render_fov() -> void:
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], Game_NinjaData.PC_SIGHT,
			self, "_block_line_of_sight", [])

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainGroupTag.DUNGEON_OBJECT:
				if (i == Game_MainGroupTag.BUILDING) \
						or (i == Game_MainGroupTag.GROUND):
					_set_sprite_color_with_memory(x, y, i, "", true,
							_new_ShadowCastFOV, "is_in_sight")
				else:
					_set_sprite_color(x, y, i, "",
							_new_ShadowCastFOV, "is_in_sight")


func wait() -> void:
	if _is_time_stop:
		_switch_time_stop(false)
	.wait()


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_actor(x, y)


func _switch_time_stop(stop_time: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if stop_time:
		_count_time_stop = Game_NinjaData.MAX_TIME_STOP
		_ref_SwitchSprite.switch_sprite(pc,
				_new_SpriteTypeTag.convert_digit_to_tag(_count_time_stop))
		_is_time_stop = true
	else:
		_ref_SwitchSprite.switch_sprite(pc, Game_SpriteTypeTag.DEFAULT)
		_is_time_stop = false
