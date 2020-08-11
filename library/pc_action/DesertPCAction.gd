extends "res://library/pc_action/PCActionTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func wait() -> void:
	if _pc_is_dead():
		_ref_EndGame.player_lose()
	else:
		end_turn = false


# TODO: Fill progress bar.
func attack() -> void:
	if _pc_is_dead():
		_ref_EndGame.player_lose()
		return

	var x: int = _target_position[0]
	var y: int = _target_position[1]
	var worm: Sprite = _ref_DungeonBoard.get_sprite(
			_new_MainGroupTag.ACTOR, x, y)

	if (not worm.is_in_group(_new_SubGroupTag.SPICE)) \
			or _ref_ObjectData.verify_state(worm, _new_ObjectStateTag.PASSIVE):
		end_turn = false
		return

	_ref_ObjectData.set_state(worm, _new_ObjectStateTag.PASSIVE)
	_ref_SwitchSprite.switch_sprite(worm, _new_SpriteTypeTag.PASSIVE)
	_ref_CountDown.hit_bonus()
	end_turn = true


# TODO: Fill progress bar.
func interact_with_trap() -> void:
	_ref_CountDown.hit_bonus()
	_remove_building_or_trap(false)


func interact_with_building() -> void:
	_remove_building_or_trap(true)


func _remove_building_or_trap(is_building: bool) -> void:
	var x: int = _target_position[0]
	var y: int = _target_position[1]

	if is_building:
		_ref_RemoveObject.remove(_new_MainGroupTag.BUILDING, x, y)
	else:
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
	end_turn = true


func _pc_is_dead() -> bool:
	var x: int = _source_position[0]
	var y: int = _source_position[1]

	var neighbor: Array = _new_CoordCalculator.get_neighbor(x, y, 1)
	var max_neighbor: int = 4
	var count_neighbor: int = max_neighbor - neighbor.size()

	var actor: Sprite
	var is_worm: bool
	var is_spice: bool
	var is_passive: bool

	for i in neighbor:
		actor = _ref_DungeonBoard.get_sprite(
				_new_MainGroupTag.ACTOR, i[0], i[1])
		if (actor == null):
			continue

		is_worm = actor.is_in_group(_new_SubGroupTag.WORM)
		is_spice = actor.is_in_group(_new_SubGroupTag.SPICE)
		is_passive = _ref_ObjectData.verify_state(
				actor, _new_ObjectStateTag.PASSIVE)

		if is_worm or (is_spice and is_passive):
			count_neighbor += 1

	return count_neighbor == max_neighbor
