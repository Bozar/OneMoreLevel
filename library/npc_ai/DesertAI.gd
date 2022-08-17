extends Game_AITemplate


# int: Array[Sprite]
const ID_TO_WORM := {}
# int: bool
const ID_TO_HAS_ACTIVE_SPICE := {}

var _spr_WormBody := preload("res://sprite/WormBody.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_WormTail := preload("res://sprite/WormTail.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")

var _quality_spice_chance := Game_DesertData.CREATE_QUALITY_SPICE


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if not _self.is_in_group(Game_SubTag.WORM_HEAD):
		return

	var id: int = _self.get_instance_id()

	if not ID_TO_WORM.has(id):
		_init_worm(id)

	# A newly created worm waits one turn.
	if _ref_ObjectData.verify_state(_self, Game_StateTag.PASSIVE):
		_ref_ObjectData.set_state(_self, Game_StateTag.DEFAULT)
		return
	if _can_bury_worm(id):
		_set_danger_zone(_self, false)
		_bury_worm(id)
		return

	# Try to move head.
	if _try_random_walk(id):
		# Move body.
		_move_body(id)
	else:
		_ref_ObjectData.add_hit_point(_self, Game_DesertData.HP_WAIT)
	_ref_ObjectData.add_hit_point(_self, Game_DesertData.HP_TURN)


func _init_worm(id: int) -> void:
	var worm_length := _ref_RandomNumber.get_int(
			Game_DesertData.MIN_LENGTH, Game_DesertData.MAX_LENGTH)

	ID_TO_WORM[id] = []
	ID_TO_WORM[id].resize(worm_length)
	ID_TO_WORM[id][0] = _self

	ID_TO_HAS_ACTIVE_SPICE[id] = false
	_set_danger_zone(_self, true)


func _create_body(id: int, index: int, coord: Game_IntCoord) -> void:
	var worm_length: int = ID_TO_WORM[id].size()
	var is_active := false
	var worm_body: Sprite

	# Create tail.
	if index == worm_length - 1:
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormTail,
				Game_SubTag.WORM_BODY, coord)
	# Create spice.
	elif (index >= Game_DesertData.SPICE_START) \
			and (index < Game_DesertData.SPICE_END):
		is_active = (not ID_TO_HAS_ACTIVE_SPICE[id]) \
				and _ref_RandomNumber.get_percent_chance(_quality_spice_chance)
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormSpice,
				Game_SubTag.WORM_SPICE, coord)
	# Create body.
	else:
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormBody,
				Game_SubTag.WORM_BODY, coord)
	ID_TO_WORM[id][index] = worm_body

	if is_active:
		_ref_ObjectData.set_state(worm_body, Game_StateTag.ACTIVE)
		_ref_SwitchSprite.set_sprite(worm_body, Game_SpriteTypeTag.ACTIVE)
		ID_TO_HAS_ACTIVE_SPICE[id] = true
		_quality_spice_chance = 0


func _try_random_walk(id: int) -> bool:
	var neck: Game_IntCoord
	var forward: Game_IntCoord
	var side := []
	var has_forward: bool
	var has_side: bool
	var move_to: Game_IntCoord
	var pc := _ref_DungeonBoard.get_pc()

	if ID_TO_WORM[id][1] != null:
		neck = Game_ConvertCoord.sprite_to_coord(ID_TO_WORM[id][1])

	for i in Game_CoordCalculator.get_neighbor(_self_pos, 1):
		# A sandworm segment.
		if _ref_DungeonBoard.has_actor(i) and (not _is_pc_pos(i)):
			continue
		# A grid that is in a straight line with neck.
		elif (neck != null) and ((i.x == neck.x) or (i.y == neck.y)):
			forward = i
		else:
			side.push_back(i)

	has_forward = (forward != null)
	has_side = (side.size() > 0)
	if _can_move_forward(has_forward, has_side):
		move_to = forward
	elif has_side:
		Game_ArrayHelper.shuffle(side, _ref_RandomNumber)
		move_to = side[0]
	else:
		return false

	if _is_pc_pos(move_to):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.ACTIVE)
		_ref_SwitchSprite.set_sprite(_self, Game_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
		return false

	_ref_RemoveObject.remove_building(move_to)
	_ref_RemoveObject.remove_trap(move_to)

	_set_danger_zone(_self, false)
	_ref_DungeonBoard.move_actor(_self_pos, move_to)
	_set_danger_zone(_self, true)
	return true


func _can_move_forward(has_forward: bool, has_side: bool) -> bool:
	return has_forward and (not has_side \
			or _ref_RandomNumber.get_percent_chance(
					Game_DesertData.MOVE_STRAIGHT))


func _is_pc_pos(coord: Game_IntCoord) -> bool:
	return (coord.x == _pc_pos.x) and (coord.y == _pc_pos.y)


func _move_body(id: int) -> void:
	var worm: Array = ID_TO_WORM[id]
	var current_position: Game_IntCoord = _self_pos
	var save_position: Game_IntCoord

	for i in range(1, worm.size()):
		if worm[i] == null:
			_create_body(id, i, current_position)
			return

		save_position = Game_ConvertCoord.sprite_to_coord(worm[i])
		_ref_DungeonBoard.move_actor(save_position, current_position)
		current_position = save_position


func _bury_worm(id: int) -> void:
	var worm: Array = ID_TO_WORM[id]
	var create_spice := Game_DesertData.CREATE_SPICE
	var pos: Game_IntCoord

	for i in range(Game_DesertData.SPICE_END):
		if worm[i] == null:
			break
		if _has_spice(worm[i]) and (not _is_passive_spice(worm[i])):
			create_spice += Game_DesertData.BONUS_CREATE_SPICE

	for i in worm:
		if i == null:
			break
		pos = Game_ConvertCoord.sprite_to_coord(i)
		_ref_RemoveObject.remove_actor(pos)
		if _ref_RandomNumber.get_percent_chance(create_spice):
			_ref_CreateObject.create_trap(_spr_Treasure, Game_SubTag.TREASURE,
					pos)
		else:
			_ref_CreateObject.create_building(_spr_Wall, Game_SubTag.WALL, pos)

	_clear_worm_data(id)
	_quality_spice_chance += Game_DesertData.CREATE_QUALITY_SPICE


func _can_bury_worm(id: int) -> bool:
	var worm: Array = ID_TO_WORM[id]
	var hit_point := _ref_ObjectData.get_hit_point(worm[0])

	for i in worm:
		if i == null:
			break
		if _has_spice(i) and _is_passive_spice(i):
			hit_point -= Game_DesertData.HP_SPICE
	return hit_point > Game_DesertData.HP_BURY


func _set_danger_zone(head: Sprite, is_danger: bool) -> void:
	var pos := Game_ConvertCoord.sprite_to_coord(head)
	var neighbor := Game_CoordCalculator.get_neighbor(pos, 1)

	for i in neighbor:
		_ref_DangerZone.set_danger_zone(i.x, i.y, is_danger)


func _is_passive_spice(spice: Sprite) -> bool:
	return _ref_ObjectData.verify_state(spice, Game_StateTag.PASSIVE)


func _has_spice(body: Sprite) -> bool:
	return body.is_in_group(Game_SubTag.WORM_SPICE)


func _clear_worm_data(id: int) -> void:
	var __
	__ = ID_TO_WORM.erase(id)
	__ = ID_TO_HAS_ACTIVE_SPICE.erase(id)
