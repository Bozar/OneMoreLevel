extends Game_PCActionTemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


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


# Use interact_with_building() to move PC.
func move() -> void:
	end_turn = false


func attack() -> void:
	_ref_RemoveObject.remove_actor(_target_position.x, _target_position.y,
			Game_BaronData.TREE_LAYER)
	_move_in_tree()
	end_turn = true


func interact_with_building() -> void:
	_move_in_tree()
	end_turn = true


func _move_in_tree() -> void:
	_ref_DungeonBoard.move_actor(_source_position.x, _source_position.y,
			_target_position.x, _target_position.y, Game_BaronData.TREE_LAYER)
