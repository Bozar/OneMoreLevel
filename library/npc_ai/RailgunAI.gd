extends "res://library/npc_ai/AITemplate.gd"


const DIRECTION_TO_SHIFT: Dictionary = {
	1: [1, 0],
	2: [0, 1],
	-1: [-1, 0],
	-2: [0, -1],
}

var _spr_Treasure := preload("res://sprite/Treasure.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if _ref_ObjectData.verify_state(_self, _new_ObjectStateTag.ACTIVE):
		_switch_mode(false)
		_attack()
	elif _is_in_close_range():
		_switch_mode(true)
	elif _new_CoordCalculator.is_inside_range(
			_self_pos[0], _self_pos[1], _pc_pos[0], _pc_pos[1],
			_new_RailgunData.NPC_SIGHT):
		_approach_pc()
		_try_remove_trap()


func _switch_mode(aim_mode: bool) -> void:
	var new_state: String
	var new_sprite: String

	if aim_mode:
		new_state = _new_ObjectStateTag.ACTIVE
		new_sprite = _new_SpriteTypeTag.ACTIVE
	else:
		new_state = _new_ObjectStateTag.DEFAULT
		new_sprite = _new_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(_self, new_state)
	_ref_SwitchSprite.switch_sprite(_self, new_sprite)


func _attack() -> void:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var hit_point: int = _ref_ObjectData.get_hit_point(_self)
	var shift_x: int = DIRECTION_TO_SHIFT[hit_point][0]
	var shift_y: int = DIRECTION_TO_SHIFT[hit_point][1]

	while true:
		self_x += shift_x
		self_y += shift_y

		if _block_ray(self_x, self_y):
			return
		elif _is_actor(self_x, self_y):
			if (self_x == pc_x) and (self_y == pc_y):
				_ref_EndGame.player_lose()
				_ref_SwitchSprite.switch_sprite(_self,
						_new_SpriteTypeTag.ACTIVE_1)
				_self.visible = true
			else:
				_ref_RemoveObject.remove(_new_MainGroupTag.ACTOR,
						self_x, self_y)
				_ref_CreateObject.create(_spr_Treasure,
						_new_MainGroupTag.TRAP, _new_SubGroupTag.TREASURE,
						self_x, self_y)
			return


func _is_in_close_range() -> bool:
	var self_x: int = _self_pos[0]
	var self_y: int = _self_pos[1]
	var pc_x: int = _pc_pos[0]
	var pc_y: int = _pc_pos[1]
	var shift_x: int
	var shift_y: int

	if (self_x != pc_x) and (self_y != pc_y):
		return false
	elif not _new_CoordCalculator.is_inside_range(self_x, self_y, pc_x, pc_y,
			_new_RailgunData.PC_SIDE_SIGHT):
		return false

	shift_x = _get_direction(self_x, pc_x)
	shift_y = _get_direction(self_y, pc_y)
	while true:
		self_x += shift_x
		self_y += shift_y

		if _block_ray(self_x, self_y):
			return false
		elif _is_actor(self_x, self_y):
			if (self_x == pc_x) and (self_y == pc_y):
				_ref_ObjectData.set_hit_point(_self,
						_get_hit_point(shift_x, shift_y))
				return true
			return false
	return false


func _get_direction(source: int, target: int) -> int:
	var delta: int = target - source
	if delta > 0:
		return 1
	elif delta < 0:
		return -1
	return 0


func _get_hit_point(shift_x: int, shift_y: int) -> int:
	return shift_x + shift_y * 2


func _block_ray(x: int, y: int) -> bool:
	return (not _new_CoordCalculator.is_inside_dungeon(x, y)) \
			or _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y)


func _is_actor(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR, x, y)


func _try_remove_trap() -> void:
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP,
			_target_pos[0], _target_pos[1]):
		_ref_RemoveObject.remove(_new_MainGroupTag.TRAP,
				_target_pos[0], _target_pos[1])
