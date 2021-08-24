extends Game_PCActionTemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func render_fov() -> void:
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	_new_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], _fov_render_range,
			self, "_block_line_of_sight", [])

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainGroupTag.DUNGEON_OBJECT:
				_set_sprite_color_with_memory(x, y, i, "",
						i != Game_MainGroupTag.ACTOR,
						_new_ShadowCastFOV, "is_in_sight")


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	if _ref_DungeonBoard.has_building(x, y) \
			or _ref_DungeonBoard.has_actor(x, y):
		return true
	return false
