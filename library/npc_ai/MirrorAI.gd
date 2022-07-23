extends Game_AITemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var distance: int

	if _self.is_in_group(Game_SubTag.PC_MIRROR_IMAGE):
		return
	elif not _ref_ObjectData.verify_state(_self, Game_StateTag.PASSIVE):
		distance = Game_CoordCalculator.get_range(_self_pos, _pc_pos)
		if distance == Game_MirrorData.ATTACK_RANGE:
			_switch_pc_and_image()
			_set_npc_state()
		elif distance <= Game_MirrorData.PHANTOM_SIGHT:
			_approach_pc()


func _switch_pc_and_image() -> void:
	var mirror_coord := Game_CoordCalculator.get_mirror_image_xy(
			_pc_pos.x, _pc_pos.y, Game_DungeonSize.CENTER_X, _pc_pos.y)
	_ref_DungeonBoard.swap_sprite(Game_MainTag.ACTOR, _pc_pos, mirror_coord)


func _set_npc_state() -> void:
	var npc_pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_npc():
		if i.is_in_group(Game_SubTag.PC_MIRROR_IMAGE):
			continue
		elif _ref_ObjectData.verify_state(i, Game_StateTag.DEFAULT):
			_ref_ObjectData.set_state(i, Game_StateTag.PASSIVE)
			npc_pos = Game_ConvertCoord.sprite_to_coord(i)
			if _ref_DungeonBoard.has_trap(npc_pos):
				_ref_RemoveObject.remove_trap(npc_pos)
		else:
			_ref_ObjectData.set_state(i, Game_StateTag.DEFAULT)
