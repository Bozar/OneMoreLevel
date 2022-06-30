extends Game_PCActionTemplate


var _spr_TreeTrunk := preload("res://sprite/TreeTrunk.tscn")

var _count_bandits := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_BaronData.FAR_SIGHT


func is_npc() -> bool:
	return _ref_DungeonBoard.has_actor(_target_position.x, _target_position.y,
			Game_BaronData.TREE_LAYER)


func is_trap() -> bool:
	return false


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var tree_sprite := _ref_DungeonBoard.get_building(
			_source_position.x, _source_position.y)

	if tree_sprite.is_in_group(Game_SubTag.TREE_BRANCH):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.ACTIVE)
	# A marked tree trunk.
	elif _ref_ObjectData.get_bool(tree_sprite):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT_1)
	else:
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)


func render_fov() -> void:
	var pc_pos := _ref_DungeonBoard.get_pc_coord()
	var this_pos: Game_IntCoord
	var sprite_layer: int

	_set_render_sprites()
	Game_ShadowCastFOV.set_field_of_view(
			Game_DungeonSize.MAX_X, Game_DungeonSize.MAX_Y,
			pc_pos.x, pc_pos.y, _fov_render_range,
			self, "_block_line_of_sight", [])

	if _ref_GameSetting.get_show_full_map():
		_render_without_fog_of_war()
		return

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			this_pos = Game_ConvertCoord.vector_to_coord(i.position)
			if _is_above_ground_actor(i):
				sprite_layer = Game_BaronData.TREE_LAYER
			else:
				sprite_layer = 0
			_set_sprite_color(this_pos.x, this_pos.y, mtag, Game_ShadowCastFOV,
					"is_in_sight", sprite_layer)

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.COUNTER):
		_ref_Palette.set_default_color(i, Game_MainTag.BUILDING)


# Use interact_with_building() to move PC.
func move() -> void:
	end_turn = false


func attack() -> void:
	_ref_RemoveObject.remove_actor(_target_position.x, _target_position.y,
			Game_BaronData.TREE_LAYER)
	interact_with_building()


func interact_with_building() -> void:
	_move_in_tree()
	_try_find_bandit()


func wait() -> void:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_SubTag.TREE_BRANCH,
			_source_position.x, _source_position.y):
		end_turn = false
	else:
		_try_find_bandit()


func _move_in_tree() -> void:
	_ref_DungeonBoard.move_actor(_source_position.x, _source_position.y,
			_target_position.x, _target_position.y, Game_BaronData.TREE_LAYER)


func _sprite_is_visible(main_tag: String, x: int, y: int, _use_memory: bool,
		sprite_layer := 0) -> bool:
	var ground_actor := _ref_DungeonBoard.get_actor(x, y)

	match main_tag:
		Game_MainTag.GROUND:
			if ground_actor == null:
				return true
			return not Game_ShadowCastFOV.is_in_sight(x, y)
		Game_MainTag.BUILDING:
			return not _ref_DungeonBoard.has_actor(x, y,
					Game_BaronData.TREE_LAYER)
		Game_MainTag.ACTOR:
			if sprite_layer == Game_BaronData.TREE_LAYER:
				return true
			elif _ref_DungeonBoard.has_building(x, y):
				return false
			return Game_ShadowCastFOV.is_in_sight(x, y)
	return true


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	var building := _ref_DungeonBoard.get_building(x, y)
	return (building != null) and (building.is_in_group(Game_SubTag.TREE_TRUNK))


func _render_without_fog_of_war() -> void:
	var pos: Game_IntCoord

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			pos = Game_ConvertCoord.vector_to_coord(i.position)
			if _is_above_ground_actor(i):
				i.visible = true
			else:
				i.visible = _sprite_is_visible(mtag, pos.x, pos.y, false)
			if mtag == Game_MainTag.GROUND:
				_ref_Palette.set_dark_color(i, mtag)


func _is_above_ground_actor(actor: Sprite) -> bool:
	return actor.is_in_group(Game_SubTag.BIRD) \
			or actor.is_in_group(Game_SubTag.PC)


func _try_find_bandit() -> void:
	var pos: Game_IntCoord
	var has_minor_find := false
	var has_major_find := false
	var restore_turn := 0
	var win := false

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BANDIT):
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		if Game_ShadowCastFOV.is_in_sight(pos.x, pos.y) \
				and not _ref_DungeonBoard.has_building(pos.x, pos.y):
			_ref_ObjectData.add_hit_point(i, 1)
			if _ref_ObjectData.get_hit_point(i) == Game_BaronData.MAX_HP:
				has_major_find = true
				_count_bandits += 1
				_ref_RemoveObject.remove_actor(pos.x, pos.y)
			else:
				has_minor_find = true

	if has_major_find:
		restore_turn = Game_BaronData.MAJOR_RESTORE
	elif has_minor_find:
		restore_turn = Game_BaronData.MINOR_RESTORE

	for i in range(0, Game_BaronData.BANDIT_LEVEL.size()):
		if _count_bandits > Game_BaronData.BANDIT_LEVEL[i]:
			_fov_render_range = Game_BaronData.SIGHT_LEVEL[i]
			break

	if _count_bandits == Game_BaronData.MAX_BANDIT:
		win = true
	elif _ref_CountDown.get_count(false) == 1:
		if _count_bandits >= Game_BaronData.MIN_BANDIT:
			win = true

	if win:
		_ref_EndGame.player_win()
		end_turn = false
	else:
		_ref_CountDown.add_count(restore_turn)
		end_turn = true
