extends Game_PCActionTemplate


var find_doors := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func render_fov() -> void:
	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		_render_doors(true)
		return

	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			_source_position[0], _source_position[1], _fov_render_range,
			self, "_block_line_of_sight", [])

	for x in range(Game_DungeonSize.MAX_X):
		for y in range(Game_DungeonSize.MAX_Y):
			for i in Game_MainGroupTag.DUNGEON_OBJECT:
				_set_sprite_color_with_memory(x, y, i, "",
						i != Game_MainGroupTag.ACTOR,
						Game_ShadowCastFOV, "is_in_sight")

	_render_doors(false)


func interact_with_building() -> void:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubGroupTag.DOOR,
			_target_position[0], _target_position[1]):
		move()


func _render_doors(auto_reset: bool) -> void:
	var pos: Array

	if find_doors.size() == 0:
		find_doors = _ref_DungeonBoard.get_sprites_by_tag(Game_SubGroupTag.DOOR)
	for i in find_doors:
		pos = Game_ConvertCoord.vector_to_array(i.position)
		if _ref_DungeonBoard.has_actor(pos[0], pos[1]):
			i.visible = false
		elif auto_reset:
			i.visible = true
