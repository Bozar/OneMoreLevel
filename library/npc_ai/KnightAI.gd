extends Game_AITemplate


const HIT_TO_SPRITE := {
	0: Game_SpriteTypeTag.DEFAULT,
	1: Game_SpriteTypeTag.DEFAULT_2,
	2: Game_SpriteTypeTag.DEFAULT_3,
}

var _id_to_danger_zone := {}
var _boss_attack_count := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	# Active -> Passive.
	if _ref_ObjectData.verify_state(_self, Game_StateTag.ACTIVE):
		_attack()
	# Passive -> Default.
	elif _ref_ObjectData.verify_state(_self, Game_StateTag.PASSIVE):
		_recover()
	# Default -> Active.
	elif Game_CoordCalculator.is_inside_range(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, Game_KnightData.RANGE):
		_alert()
	# Approach.
	elif _is_ready_to_move():
		_approach_pc()


func remove_data(actor: Sprite) -> void:
	var id: int = actor.get_instance_id()
	var __

	__ = _id_to_danger_zone.erase(id)


func _attack() -> void:
	var id: int = _self.get_instance_id()
	var danger_zone: Array = _id_to_danger_zone[id]

	_try_hit_pc(danger_zone)
	_set_danger_zone(danger_zone, false)
	_switch_ground(danger_zone)

	if _can_attack_twice():
		_prepare_second_attack(id)
	else:
		_ref_ObjectData.set_state(_self, Game_StateTag.PASSIVE)
		_ref_SwitchSprite.switch_sprite(_self, Game_SpriteTypeTag.PASSIVE)


func _recover() -> void:
	var hit: int = _ref_ObjectData.get_hit_point(_self)
	var new_sprite: String = Game_SpriteTypeTag.DEFAULT

	_ref_ObjectData.set_state(_self, Game_StateTag.DEFAULT)

	if _self.is_in_group(Game_SubTag.KNIGHT_BOSS) and HIT_TO_SPRITE.has(hit):
		new_sprite = HIT_TO_SPRITE[hit]
	_ref_SwitchSprite.switch_sprite(_self, new_sprite)


func _alert() -> void:
	var id: int = _self.get_instance_id()
	var danger_zone: Array = _get_danger_zone()

	_ref_ObjectData.set_state(_self, Game_StateTag.ACTIVE)
	_ref_SwitchSprite.switch_sprite(_self, Game_SpriteTypeTag.ACTIVE)

	_id_to_danger_zone[id] = danger_zone
	_set_danger_zone(danger_zone, true)
	_switch_ground(danger_zone)

	# if _self.is_in_group(Game_SubTag.KNIGHT_BOSS) \
	# 		and _ref_ObjectData.get_hit_point(_self) < _max_boss_hp:
	# 	_ref_ObjectData.add_hit_point(_self, 1)

	if _is_final_boss():
		_boss_attack_count = 0


func _switch_ground(danger_zone: Array) -> void:
	var ground_sprite: Sprite
	var sprite_type: String

	for i in danger_zone:
		ground_sprite= _ref_DungeonBoard.get_ground(i.x, i.y)
		if _ref_DangerZone.is_in_danger(i.x, i.y):
			sprite_type = Game_SpriteTypeTag.ACTIVE
		else:
			sprite_type = Game_SpriteTypeTag.DEFAULT
		_ref_SwitchSprite.switch_sprite(ground_sprite, sprite_type)


func _get_danger_zone() -> Array:
	var neighbor: Array = Game_CoordCalculator.get_neighbor(
			_pc_pos.x, _pc_pos.y, 1, true)
	var candidate: Array = [_pc_pos]
	var one_grid: Array = []
	var two_grids: Array = []
	var four_grids: Array = []
	var danger_zone: Array

	for i in neighbor:
		if _ref_DungeonBoard.has_building(i.x, i.y):
			continue
		elif (i.x == _self_pos.x) and (i.y == _self_pos.y):
			continue
		candidate.push_back(i)

	one_grid = [_pc_pos]
	for i in candidate:
		if (i.x == _self_pos.x) or (i.y == _self_pos.y):
			two_grids.push_back(i)
	four_grids = candidate

	if _self.is_in_group(Game_SubTag.KNIGHT):
		danger_zone = one_grid
	elif _self.is_in_group(Game_SubTag.KNIGHT_CAPTAIN):
		danger_zone = two_grids
	elif _self.is_in_group(Game_SubTag.KNIGHT_BOSS):
		if _ref_ObjectData.get_hit_point(_self) > 0:
			danger_zone = four_grids
		else:
			danger_zone = two_grids

	return danger_zone


func _is_final_boss() -> bool:
	return _self.is_in_group(Game_SubTag.KNIGHT_BOSS) \
			and (_ref_ObjectData.get_hit_point(_self)
					== Game_KnightData.MAX_BOSS_HP)


func _can_attack_twice() -> bool:
	if not _is_final_boss():
		return false
	if _boss_attack_count > 0:
		return false
	if not Game_CoordCalculator.is_inside_range(_pc_pos.x, _pc_pos.y,
			_self_pos.x, _self_pos.y, Game_KnightData.RANGE):
		return false
	return true


func _prepare_second_attack(id: int) -> void:
	var danger_zone: Array = _get_danger_zone()

	_id_to_danger_zone[id] = danger_zone
	_set_danger_zone(danger_zone, true)
	_switch_ground(danger_zone)

	_boss_attack_count += 1


func _set_danger_zone(danger_zone: Array, is_dangerous: bool) -> void:
	for i in danger_zone:
		_ref_DangerZone.set_danger_zone(i.x, i.y, is_dangerous)


func _try_hit_pc(danger_zone: Array) -> void:
	var victim: Sprite

	for i in danger_zone:
		victim = _ref_DungeonBoard.get_actor(i.x, i.y)
		if victim == null:
			continue
		if victim.is_in_group(Game_SubTag.PC):
			_ref_EndGame.player_lose()
			# print("pc dead")
		elif victim.is_in_group(Game_SubTag.KNIGHT) \
				and _ref_ObjectData.verify_state(victim, Game_StateTag.PASSIVE):
			_ref_RemoveObject.remove_actor(i.x, i.y)
			_ref_CountDown.add_count(Game_KnightData.RESTORE_TURN)


func _is_ready_to_move() -> bool:
	var sight: int
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _ref_ObjectData.verify_state(pc, Game_StateTag.PASSIVE):
		sight = Game_KnightData.SNEAK_SIGHT
	elif _self.is_in_group(Game_SubTag.KNIGHT):
		sight = Game_KnightData.SIGHT
	else:
		sight = Game_KnightData.ELITE_SIGHT

	return Game_CoordCalculator.is_inside_range(_self_pos.x, _self_pos.y,
			_pc_pos.x, _pc_pos.y, sight)
