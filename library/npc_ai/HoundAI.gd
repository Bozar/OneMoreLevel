extends "res://library/npc_ai/AITemplate.gd"


const INIT_DURATION: int = -1

var _new_HoundData := preload("res://library/npc_data/HoundData.gd").new()

var _boss_duration: int = INIT_DURATION
var _boss_escape: int = 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if _self.is_in_group(_new_SubGroupTag.HOUND_BOSS):
		if not _boss_countdown():
			return

	_switch_sprite()


func _switch_sprite() -> void:
	var pos: Array = _new_ConvertCoord.vector_to_array(_self.position)
	var ground: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.GROUND,
			pos[0], pos[1])
	var hit_point: int
	var sprite_type: String

	if _ref_ObjectData.verify_state(ground, _new_ObjectStateTag.ACTIVE):
		if _self.is_in_group(_new_SubGroupTag.HOUND_BOSS):
			hit_point = _ref_ObjectData.get_hit_point(_self)
			sprite_type = _new_SpriteTypeTag.convert_digit_to_tag(hit_point)
		else:
			sprite_type = _new_SpriteTypeTag.ACTIVE
	else:
		sprite_type = _new_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.switch_sprite(_self, sprite_type)


func _boss_countdown() -> bool:
	var boss_to_pc: int
	var extra_duration: int

	if _boss_duration == INIT_DURATION:
		boss_to_pc = _new_CoordCalculator.get_range(_self_pos[0], _self_pos[1],
				_pc_pos[0], _pc_pos[1])
		extra_duration = _ref_RandomNumber.get_int(
				_new_HoundData.MIN_BOSS_DURATION,
				_new_HoundData.MAX_BOSS_DURATION)
		_boss_duration = boss_to_pc + extra_duration

	if _boss_duration > 0:
		_boss_duration -= 1
		return true
	else:
		_boss_duration = INIT_DURATION
		_boss_escape += 1
		_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
				_self_pos[0], _self_pos[1])
		if _boss_escape == _new_HoundData.MAX_BOSS_ESCAPE:
			_ref_EndGame.player_win()
		return false
