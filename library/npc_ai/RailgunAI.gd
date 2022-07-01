extends Game_AITemplate


const DIRECTION_TO_SHIFT: Dictionary = {
	1: [1, 0],
	2: [0, 1],
	-1: [-1, 0],
	-2: [0, -1],
}

var _spr_Treasure := preload("res://sprite/Treasure.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if _ref_ObjectData.verify_state(_self, Game_StateTag.ACTIVE):
		_switch_mode(false)
		_attack()
	elif _is_in_close_range():
		_switch_mode(true)
	elif _detect_pc():
		# if Game_CoordCalculator.get_range_xy(_self_pos.x, _self_pos.y,
		# 		_pc_pos.x, _pc_pos.y) > Game_RailgunData.NPC_SIGHT:
		# 	_self.modulate = _ref_Palette.DEBUG
		# 	print("gunshot")
		_approach_pc()
		_ref_RemoveObject.remove_trap(_self_pos.x, _self_pos.y)


func _switch_mode(aim_mode: bool) -> void:
	var new_state: int
	var new_sprite: String

	if aim_mode:
		new_state = Game_StateTag.ACTIVE
		new_sprite = Game_SpriteTypeTag.ACTIVE
	else:
		new_state = Game_StateTag.DEFAULT
		new_sprite = Game_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(_self, new_state)
	_ref_SwitchSprite.set_sprite(_self, new_sprite)


func _attack() -> void:
	var self_x: int = _self_pos.x
	var self_y: int = _self_pos.y
	var pc_x: int = _pc_pos.x
	var pc_y: int = _pc_pos.y
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
				_ref_SwitchSprite.set_sprite(_self,
						Game_SpriteTypeTag.ACTIVE_1)
				_self.visible = true
			else:
				_ref_RemoveObject.remove_actor(self_x, self_y)
				_ref_CreateObject.create_trap(_spr_Treasure,
						Game_SubTag.TREASURE, self_x, self_y)
			return


func _is_in_close_range() -> bool:
	var self_x: int = _self_pos.x
	var self_y: int = _self_pos.y
	var pc_x: int = _pc_pos.x
	var pc_y: int = _pc_pos.y
	var shift_x: int
	var shift_y: int

	if (self_x != pc_x) and (self_y != pc_y):
		return false
	elif not Game_CoordCalculator.is_inside_range_xy(self_x, self_y, pc_x, pc_y,
			Game_RailgunData.PC_SIDE_SIGHT):
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
	return (not Game_CoordCalculator.is_inside_dungeon(x, y)) \
			or _ref_DungeonBoard.has_building_xy(x, y)


func _is_actor(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_actor_xy(x, y)


func _detect_pc() -> bool:
	var detect_distance: int
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.get_hit_point(pc) > Game_RailgunData.GUN_SHOT_HP:
		detect_distance = Game_RailgunData.NPC_EAR_SHOT
	else:
		detect_distance = Game_RailgunData.NPC_SIGHT
	return Game_CoordCalculator.is_inside_range_xy(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, detect_distance)
