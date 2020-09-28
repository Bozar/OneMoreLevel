extends "res://library/npc_ai/AITemplate.gd"


var _new_MirrorData := preload("res://library/npc_data/MirrorData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action(actor: Sprite) -> void:
	if _ref_ObjectData.verify_state(actor, _new_ObjectStateTag.PASSIVE):
		return

	_set_local_var(actor)

	var distance: int = _new_CoordCalculator.get_range(
			_self_pos[0], _self_pos[1],
			_pc_pos[0], _pc_pos[1])

	if distance > _new_MirrorData.PHANTOM_SIGHT:
		return
	elif distance == _new_MirrorData.ATTACK_RANGE:
		_attack()
	else:
		_move()


func _attack() -> void:
	return


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
