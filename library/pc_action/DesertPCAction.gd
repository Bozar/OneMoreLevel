extends Game_PCActionTemplate


const MAX_NEIGHBOR := 4

var _pc_is_number := false


func _init(parent_node: Node2D).(parent_node) -> void:
	_fov_render_range = Game_DesertData.RENDER_RANGE


func switch_sprite() -> void:
	_pc_is_number = false
	_switch_to_number(_pc_is_number)
	.switch_sprite()


func game_over(win: bool) -> void:
	_render_end_game(win)
	_switch_to_number(not win)


func wait() -> void:
	_pc_is_number = not _pc_is_number
	_switch_to_number(_pc_is_number)
	end_turn = false


func attack() -> void:
	var worm := _ref_DungeonBoard.get_actor(_target_position)
	var is_active_spice := _ref_ObjectData.verify_state(worm,
			Game_StateTag.ACTIVE)
	var pc := _ref_DungeonBoard.get_pc()

	if (not worm.is_in_group(Game_SubTag.WORM_SPICE)) \
			or _ref_ObjectData.verify_state(worm, Game_StateTag.PASSIVE):
		end_turn = false
		return

	_ref_ObjectData.set_state(worm, Game_StateTag.PASSIVE)
	_ref_SwitchSprite.set_sprite(worm, Game_SpriteTypeTag.PASSIVE)

	if is_active_spice:
		_ref_ObjectData.add_hit_point(pc, 1)
	if _ref_ObjectData.get_hit_point(pc) < Game_DesertData.MAX_SPICE:
		_ref_CountDown.add_count(Game_DesertData.RESTORE_TURN)
		end_turn = true
	else:
		_ref_EndGame.player_win()
		end_turn = false


func interact_with_trap() -> void:
	_ref_CountDown.add_count(Game_DesertData.RESTORE_TURN)
	_remove_building_or_trap()


func interact_with_building() -> void:
	_remove_building_or_trap()


func _remove_building_or_trap() -> void:
	var x: int = _target_position.x
	var y: int = _target_position.y

	_ref_RemoveObject.remove_building_xy(x, y)
	_ref_RemoveObject.remove_trap_xy(x, y)
	end_turn = true


func _is_checkmate() -> bool:
	var neighbor := Game_CoordCalculator.get_neighbor(_source_position, 1)
	var count_neighbor := MAX_NEIGHBOR - neighbor.size()
	var actor: Sprite
	var is_head: bool
	var is_body: bool
	var is_spice: bool
	var is_passive: bool

	for i in neighbor:
		actor = _ref_DungeonBoard.get_actor(i)
		if actor == null:
			continue
		is_head = actor.is_in_group(Game_SubTag.WORM_HEAD)
		is_body = actor.is_in_group(Game_SubTag.WORM_BODY)
		is_spice = actor.is_in_group(Game_SubTag.WORM_SPICE)
		is_passive = _ref_ObjectData.verify_state(actor, Game_StateTag.PASSIVE)
		if is_head or is_body or (is_spice and is_passive):
			count_neighbor += 1
	return count_neighbor == MAX_NEIGHBOR


func _switch_to_number(is_number: bool) -> void:
	var pc: Sprite = _ref_DungeonBoard.get_pc()
	var type_tag: String

	if is_number:
		type_tag = Game_SpriteTypeTag.convert_digit_to_tag(
				_ref_ObjectData.get_hit_point(pc))
	elif _ref_DangerZone.is_in_danger(_source_position.x, _source_position.y):
		type_tag = Game_SpriteTypeTag.ACTIVE
	else:
		type_tag = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.set_sprite(pc, type_tag)


func _block_line_of_sight(x: int, y: int, _opt_arg: Array) -> bool:
	for i in Game_MainTag.ABOVE_GROUND_OBJECT:
		if _ref_DungeonBoard.has_sprite_xy(i, x, y):
			return true
	return false
