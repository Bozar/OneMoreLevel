extends Game_ProgressTemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_x: int, _pc_y: int) -> void:
	var hp: int
	var new_tag: String

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BANDIT):
		hp = Game_BaronData.MAX_HP - _ref_ObjectData.get_hit_point(i)
		new_tag = Game_SpriteTypeTag.convert_digit_to_tag(hp)
		_ref_SwitchSprite.set_sprite(i, new_tag)


func remove_actor(actor: Sprite, x: int, y: int) -> void:
	if actor.is_in_group(Game_SubTag.BANDIT):
		_mark_tree_trunk(x, y)


func create_actor(actor: Sprite, sub_tag: String, x: int, y: int) -> void:
	if sub_tag != Game_SubTag.BIRD:
		return

	var building := _ref_DungeonBoard.get_building(x, y)

	if building.is_in_group(Game_SubTag.TREE_BRANCH):
		_ref_SwitchSprite.set_sprite(actor, Game_SpriteTypeTag.ACTIVE)


func _mark_tree_trunk(x: int, y: int) -> void:
	var neighbor := Game_CoordCalculator.get_neighbor(x, y,
			Game_BaronData.FAR_SIGHT)
	var building: Sprite

	Game_ArrayHelper.shuffle(neighbor, _ref_RandomNumber)
	for i in neighbor:
		building = _ref_DungeonBoard.get_building(i.x, i.y)
		if (building == null) \
				or building.is_in_group(Game_SubTag.TREE_BRANCH) \
				or building.is_in_group(Game_SubTag.COUNTER):
			continue
		_ref_SwitchSprite.set_sprite(building, Game_SpriteTypeTag.ACTIVE)
		building.add_to_group(Game_SubTag.COUNTER)
		_ref_RemoveObject.remove_actor(i.x, i.y, Game_BaronData.TREE_LAYER)
		break
