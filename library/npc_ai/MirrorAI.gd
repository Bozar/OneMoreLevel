extends Game_AITemplate


var _trap_pos: Game_IntCoord


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var pc: Sprite
	var distance: int

	if _ref_ObjectData.verify_state(_self, Game_StateTag.PASSIVE):
		return
	elif _self.is_in_group(Game_SubTag.PC_MIRROR_IMAGE):
		return

	_trap_pos = null
	pc = _ref_DungeonBoard.get_pc()
	distance = Game_CoordCalculator.get_range(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y)

	if distance > Game_MirrorData.PHANTOM_SIGHT:
		return
	elif distance == Game_MirrorData.ATTACK_RANGE:
		_attack()
	else:
		_move()

	_try_remove_trap()
	if _ref_ObjectData.get_hit_point(pc) == Game_MirrorData.MAX_CRYSTAL:
		_ref_EndGame.player_win()


func _attack() -> void:
	_switch_pc_and_image()
	_set_npc_state()


func _move() -> void:
	var new_position: Game_IntCoord

	if _ref_DungeonBoard.has_trap(_self_pos.x, _self_pos.y):
		_ref_SwitchSprite.set_sprite(_self, Game_SpriteTypeTag.DEFAULT)

	_approach_pc()

	new_position = Game_ConvertCoord.vector_to_coord(_self.position)
	if _ref_DungeonBoard.has_trap(new_position.x, new_position.y):
		_ref_SwitchSprite.set_sprite(_self, Game_SpriteTypeTag.ACTIVE)


func _switch_pc_and_image() -> void:
	var mirror := Game_CoordCalculator.get_mirror_image(
			_pc_pos.x, _pc_pos.y, Game_DungeonSize.CENTER_X, _pc_pos.y)
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DungeonBoard.has_trap(_pc_pos.x, _pc_pos.y):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.DEFAULT)
		_trap_pos = _pc_pos

	_ref_DungeonBoard.swap_sprite(Game_MainTag.ACTOR,
			_pc_pos.x, _pc_pos.y, mirror.x, mirror.y)


func _set_npc_state() -> void:
	var npc: Array = _ref_DungeonBoard.get_npc()
	var npc_pos: Game_IntCoord

	for i in npc:
		if i.is_in_group(Game_SubTag.PC_MIRROR_IMAGE):
			continue
		elif _ref_ObjectData.verify_state(i, Game_StateTag.DEFAULT):
			_ref_ObjectData.set_state(i, Game_StateTag.PASSIVE)
			npc_pos = Game_ConvertCoord.vector_to_coord(i.position)
			if _ref_DungeonBoard.has_trap(npc_pos.x, npc_pos.y):
				_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.DEFAULT)
				_trap_pos = npc_pos
		else:
			_ref_ObjectData.set_state(i, Game_StateTag.DEFAULT)


func _try_remove_trap() -> void:
	if _trap_pos != null:
		_ref_RemoveObject.remove_trap(_trap_pos.x, _trap_pos.y)
