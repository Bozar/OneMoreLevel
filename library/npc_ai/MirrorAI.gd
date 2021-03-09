extends "res://library/npc_ai/AITemplate.gd"


var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()

var _trap_pos: Array


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if _ref_ObjectData.verify_state(_self, _new_ObjectStateTag.PASSIVE):
		return
	if _self.is_in_group(_new_SubGroupTag.PC_MIRROR_IMAGE):
		return

	_trap_pos = []

	var distance: int = _new_CoordCalculator.get_range(
			_self_pos[0], _self_pos[1],
			_pc_pos[0], _pc_pos[1])

	if distance > _new_MirrorData.PHANTOM_SIGHT:
		return
	elif distance == _new_MirrorData.ATTACK_RANGE:
		_attack()
	else:
		_move()

	_try_remove_trap()


func _attack() -> void:
	_switch_pc_and_image()
	_set_npc_state()


func _move() -> void:
	var new_position: Array
	var trap: Sprite

	trap = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.TRAP, _self_pos[0], _self_pos[1])
	if trap != null:
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.DEFAULT)
		trap.visible = true

	_approach_pc()

	new_position = _new_ConvertCoord.vector_to_array(_self.position)
	trap = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.TRAP, new_position[0], new_position[1])
	if trap != null:
		_ref_SwitchSprite.switch_sprite(_self, _new_SpriteTypeTag.ACTIVE)
		trap.visible = false


func _switch_pc_and_image() -> void:
	var mirror: Array = _new_CoordCalculator.get_mirror_image(
			_pc_pos[0], _pc_pos[1], _new_DungeonSize.CENTER_X, _pc_pos[1])
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_DungeonBoard.has_sprite(
			_new_MainGroupTag.TRAP, _pc_pos[0], _pc_pos[1]):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)
		_trap_pos = _pc_pos

	_ref_DungeonBoard.swap_sprite(_new_MainGroupTag.ACTOR,
			_pc_pos[0], _pc_pos[1],
			mirror[0], mirror[1])


func _set_npc_state() -> void:
	var npc: Array = _ref_Schedule.get_npc()
	var npc_pos: Array

	for i in npc:
		if i.is_in_group(_new_SubGroupTag.PC_MIRROR_IMAGE):
			continue

		if _ref_ObjectData.verify_state(i, _new_ObjectStateTag.DEFAULT):
			_ref_ObjectData.set_state(i, _new_ObjectStateTag.PASSIVE)
			i.modulate = _new_Palette.SHADOW

			npc_pos = _new_ConvertCoord.vector_to_array(i.position)
			if _ref_DungeonBoard.has_sprite(
					_new_MainGroupTag.TRAP, npc_pos[0], npc_pos[1]):
				_ref_SwitchSprite.switch_sprite(i, _new_SpriteTypeTag.DEFAULT)
				_trap_pos = npc_pos
		else:
			_ref_ObjectData.set_state(i, _new_ObjectStateTag.DEFAULT)
			i.modulate = _new_Palette.STANDARD


func _try_remove_trap() -> void:
	if _trap_pos.size() == 2:
		_ref_RemoveObject.remove(
				_new_MainGroupTag.TRAP, _trap_pos[0], _trap_pos[1])
