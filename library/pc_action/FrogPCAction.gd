extends "res://library/pc_action/PCActionTemplate.gd"


var _pass_next_turn: bool


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func allow_input() -> bool:
	if _pass_next_turn:
		_pass_next_turn = false
		return false
	return true


# func pass_turn() -> void:
# 	print("pass this turn")


func move() -> void:
	if not _is_on_land(_source_position[0], _source_position[1]):
		_pass_next_turn = true
	.move()


func switch_sprite() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var pc_pos: Array = _new_ConvertCoord.vector_to_array(pc.position)
	var x: int = pc_pos[0]
	var y: int = pc_pos[1]

	if _ref_DangerZone.is_in_danger(x, y):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.ACTIVE)
	elif not _is_on_land(x, y):
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.PASSIVE)
	else:
		_ref_SwitchSprite.switch_sprite(pc, _new_SpriteTypeTag.DEFAULT)


func _is_on_land(x: int, y: int) -> bool:
	var ground_sprite: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.GROUND, x, y)

	return ground_sprite.is_in_group(_new_SubGroupTag.LAND)
