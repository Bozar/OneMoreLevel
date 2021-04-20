extends "res://library/npc_ai/AITemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
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
