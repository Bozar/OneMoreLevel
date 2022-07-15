extends Game_PCActionTemplate


var _spr_TreeTrunk := preload("res://sprite/TreeTrunk.tscn")

var _count_bandits := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_BaronData.BASE_SIGHT


func is_npc() -> bool:
	return _ref_DungeonBoard.has_actor(_target_position,
			Game_BaronData.TREE_LAYER)


func is_trap() -> bool:
	return false


func switch_sprite() -> void:
	var pc := _ref_DungeonBoard.get_pc()
	var tree_sprite := _ref_DungeonBoard.get_building(_source_position)
	var new_tag := Game_SpriteTypeTag.DEFAULT

	if tree_sprite.is_in_group(Game_SubTag.TREE_BRANCH):
		new_tag = Game_SpriteTypeTag.ACTIVE
	# A marked tree trunk.
	elif tree_sprite.is_in_group(Game_SubTag.COUNTER):
		new_tag = Game_SpriteTypeTag.DEFAULT_1

	_ref_SwitchSprite.set_sprite(pc, new_tag)


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
			this_pos = Game_ConvertCoord.sprite_to_coord(i)
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
	_ref_RemoveObject.remove_actor(_target_position, Game_BaronData.TREE_LAYER)
	interact_with_building()


func interact_with_building() -> void:
	_move_in_tree()
	_try_end_turn(_try_find_bandit())


func wait() -> void:
	if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_MainTag.BUILDING,
			Game_SubTag.TREE_BRANCH, _source_position):
		end_turn = false
	else:
		_try_end_turn(_try_find_bandit())


func _move_in_tree() -> void:
	_ref_DungeonBoard.move_actor(_source_position, _target_position,
			Game_BaronData.TREE_LAYER)


func _sprite_is_visible(main_tag: String, x: int, y: int, _use_memory: bool,
		sprite_layer := 0) -> bool:
	var ground_actor := _ref_DungeonBoard.get_actor_xy(x, y)

	match main_tag:
		Game_MainTag.GROUND:
			if ground_actor == null:
				return true
			return not Game_ShadowCastFOV.is_in_sight(x, y)
		Game_MainTag.BUILDING:
			return not _ref_DungeonBoard.has_actor_xy(x, y,
					Game_BaronData.TREE_LAYER)
		Game_MainTag.ACTOR:
			if sprite_layer == Game_BaronData.TREE_LAYER:
				return true
			elif _ref_DungeonBoard.has_building_xy(x, y):
				return false
			return Game_ShadowCastFOV.is_in_sight(x, y)
	return true


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	return _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_MainTag.BUILDING,
			Game_SubTag.TREE_TRUNK, x, y)


func _render_without_fog_of_war() -> void:
	var pos: Game_IntCoord

	for mtag in RENDER_SPRITES:
		for i in RENDER_SPRITES[mtag]:
			pos = Game_ConvertCoord.sprite_to_coord(i)
			if _is_above_ground_actor(i):
				i.visible = true
			else:
				i.visible = _sprite_is_visible(mtag, pos.x, pos.y, false)
			if mtag == Game_MainTag.GROUND:
				_ref_Palette.set_dark_color(i, mtag)


func _is_above_ground_actor(actor: Sprite) -> bool:
	return actor.is_in_group(Game_SubTag.BIRD) \
			or actor.is_in_group(Game_SubTag.PC)


func _try_find_bandit() -> int:
	var pos: Game_IntCoord
	var bandits := []
	var max_hp: int
	var this_bandit: Sprite
	var hp: int
	var remaining_hp: int
	var new_tag: String

	# Find bandits in sight who are not under tree branches.
	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BANDIT):
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_ShadowCastFOV.is_in_sight(pos.x, pos.y) \
				and not _ref_DungeonBoard.has_building(pos):
			bandits.push_back(i)
	if bandits.size() < 1:
		return 0

	# Select a bandit with the most hit points.
	bandits.sort_custom(self, "_sort_by_hp")
	max_hp = _ref_ObjectData.get_hit_point(bandits[0])
	Game_ArrayHelper.filter_element(bandits, self, "_filter_by_hp", [max_hp])
	Game_ArrayHelper.rand_picker(bandits, 1, _ref_RandomNumber)

	# Add the bandit's hit point by 1.
	this_bandit = bandits[0]
	_ref_ObjectData.add_hit_point(this_bandit, 1)
	hp = _ref_ObjectData.get_hit_point(this_bandit)

	# Remove the bandit if he is fully revealed.
	if hp >= Game_BaronData.MAX_HP:
		_count_bandits += 1
		pos = Game_ConvertCoord.sprite_to_coord(this_bandit)
		_ref_RemoveObject.remove_actor(pos)
	# Otherwise, update the bandit's sprite according to his remaining hp.
	else:
		remaining_hp = Game_BaronData.MAX_HP - hp
		new_tag = Game_SpriteTypeTag.convert_digit_to_tag(remaining_hp)
		_ref_SwitchSprite.set_sprite(this_bandit, new_tag)
	return hp


# [max_hp, ..., min_hp]
func _sort_by_hp(left: Sprite, right: Sprite) -> bool:
	return _ref_ObjectData.get_hit_point(right) \
			< _ref_ObjectData.get_hit_point(left)


func _filter_by_hp(source: Array, index: int, opt_arg: Array) -> bool:
	var max_hp: int = opt_arg[0]
	return _ref_ObjectData.get_hit_point(source[index]) == max_hp


func _try_end_turn(bandit_hp: int) -> void:
	var restore_turn := 0
	var win := false

	# Set PC's turn restoration and fov range.
	if bandit_hp >= Game_BaronData.MAX_HP:
		restore_turn = Game_BaronData.FINAL_RESTORE
		# Reduce sight range if PC has found (SIGHT_THRESHOLD + 1) bandits.
		if _count_bandits > Game_BaronData.SIGHT_THRESHOLD:
			_fov_render_range = Game_BaronData.NEAR_SIGHT
	elif bandit_hp > 0:
		restore_turn = Game_BaronData.BASE_RESTORE

	# Decide if PC has won the game.
	if _count_bandits >= Game_BaronData.MAX_BANDIT:
		win = true
	elif _ref_CountDown.get_count(false) == 1:
		# Does not see any bandits on the last turn AND has already found enough
		# bandits.
		if (bandit_hp < 1) and (_count_bandits >= Game_BaronData.MIN_BANDIT):
			win = true

	if win:
		_ref_EndGame.player_win()
		end_turn = false
	else:
		_ref_CountDown.add_count(restore_turn)
		end_turn = true
