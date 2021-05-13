extends Game_AITemplate


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	_reset_butterfly()


func _reset_butterfly() -> void:
	if _self.is_in_group(Game_SubGroupTag.BUTTERFLY_NINJA):
		_ref_ObjectData.set_state(_self, Game_ObjectStateTag.DEFAULT)
		_ref_SwitchSprite.switch_sprite(_self, Game_SpriteTypeTag.DEFAULT)
