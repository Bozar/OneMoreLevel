extends Game_AITemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var pc: Sprite
	var pc_hp: int
	var npc_sight: int = Game_NinjaData.NPC_SIGHT

	_ref_ObjectData.set_state(_self, Game_ObjectStateTag.DEFAULT)
	_ref_SwitchSprite.switch_sprite(_self, Game_SpriteTypeTag.DEFAULT)

	if Game_CoordCalculator.is_inside_range(_self_pos[0], _self_pos[1],
			_pc_pos[0], _pc_pos[1], Game_NinjaData.ATTACK_RANGE):
		_ref_SwitchSprite.switch_sprite(_self, Game_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
	else:
		pc = _ref_DungeonBoard.get_pc()
		pc_hp = _ref_ObjectData.get_hit_point(pc)
		npc_sight += Game_NinjaData.ADD_NPC_SIGHT * pc_hp
		if Game_CoordCalculator.is_inside_range(_self_pos[0], _self_pos[1],
				_pc_pos[0], _pc_pos[1], npc_sight):
			_approach_pc()
