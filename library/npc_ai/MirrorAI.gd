extends Game_AITemplate


var _trap_pos: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var distance: int

	if _ref_ObjectData.verify_state(_self, _new_ObjectStateTag.PASSIVE):
		return
	elif _self.is_in_group(_new_SubGroupTag.PC_MIRROR_IMAGE):
		return

	_trap_pos = []
	pc = _ref_DungeonBoard.get_pc()
	distance = _new_CoordCalculator.get_range(_self_pos[0], _self_pos[1],
			_pc_pos[0], _pc_pos[1])

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
	var new_position: Array

	if _ref_DungeonBoard.has_trap(_self_pos[0], _self_pos[1]):
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.DEFAULT)

	_approach_pc()

	new_position = _new_ConvertCoord.vector_to_array(_self.position)
	if _ref_DungeonBoard.has_trap(new_position[0], new_position[1]):
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)


func _switch_pc_and_image() -> void:
	var mirror: Array = _new_CoordCalculator.get_mirror_image(
			_pc_pos[0], _pc_pos[1], _new_DungeonSize.CENTER_X, _pc_pos[1])
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DungeonBoard.has_trap(_pc_pos[0], _pc_pos[1]):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)
		_trap_pos = _pc_pos

	_ref_DungeonBoard.swap_sprite(_new_MainGroupTag.ACTOR,
			_pc_pos[0], _pc_pos[1],
			mirror[0], mirror[1])


func _set_npc_state() -> void:
	var npc: Array = _ref_DungeonBoard.get_npc()
	var npc_pos: Array

	for i in npc:
		if i.is_in_group(_new_SubGroupTag.PC_MIRROR_IMAGE):
			continue
		elif _ref_ObjectData.verify_state(i, _new_ObjectStateTag.DEFAULT):
			_ref_ObjectData.set_state(i, _new_ObjectStateTag.PASSIVE)
			npc_pos = _new_ConvertCoord.vector_to_array(i.position)
			if _ref_DungeonBoard.has_trap(npc_pos[0], npc_pos[1]):
				_ref_SwitchSprite.switch_sprite(i, _new_SpriteTypeTag.DEFAULT)
				_trap_pos = npc_pos
		else:
			_ref_ObjectData.set_state(i, _new_ObjectStateTag.DEFAULT)


func _try_remove_trap() -> void:
	if _trap_pos.size() == 2:
		_ref_RemoveObject.remove_trap(_trap_pos[0], _trap_pos[1])
