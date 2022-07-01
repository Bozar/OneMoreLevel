extends Game_AITemplate


var _spr_WormBody := preload("res://sprite/WormBody.tscn")
var _spr_WormSpice := preload("res://sprite/WormSpice.tscn")
var _spr_WormTail := preload("res://sprite/WormTail.tscn")
var _spr_Treasure := preload("res://sprite/Treasure.tscn")
var _spr_Wall := preload("res://sprite/Wall.tscn")

# int: Array[Sprite]
var _id_to_worm: Dictionary = {}
# int: bool
var _id_to_has_active_spice: Dictionary = {}
var _quality_spice_chance: int = Game_DesertData.CREATE_QUALITY_SPICE


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func take_action() -> void:
	if not _self.is_in_group(Game_SubTag.WORM_HEAD):
		return

	var id: int = _self.get_instance_id()

	if not _id_to_worm.has(id):
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
	var worm_length: int = _ref_RandomNumber.get_int(
			Game_DesertData.MIN_LENGTH, Game_DesertData.MAX_LENGTH)

	_id_to_worm[id] = []
	_id_to_worm[id].resize(worm_length)
	_id_to_worm[id][0] = _self

	_id_to_has_active_spice[id] = false
	_set_danger_zone(_self, true)


func _create_body(id: int, index: int, x: int, y: int) -> void:
	var worm_length: int = _id_to_worm[id].size()
	var is_active: bool = false
	var worm_body: Sprite

	# Create tail.
	if index == worm_length - 1:
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormTail,
				Game_SubTag.WORM_BODY, x, y)
	# Create spice.
	elif (index >= Game_DesertData.SPICE_START) \
			and (index < Game_DesertData.SPICE_END):
		is_active = (not _id_to_has_active_spice[id]) \
				and _ref_RandomNumber.get_percent_chance(_quality_spice_chance)
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormSpice,
				Game_SubTag.WORM_SPICE, x, y)
	# Create body.
	else:
		worm_body = _ref_CreateObject.create_and_fetch_actor(_spr_WormBody,
				Game_SubTag.WORM_BODY, x, y)
	_id_to_worm[id][index] = worm_body

	if is_active:
		_ref_ObjectData.set_state(worm_body, Game_StateTag.ACTIVE)
		_ref_SwitchSprite.set_sprite(worm_body, Game_SpriteTypeTag.ACTIVE)
		_id_to_has_active_spice[id] = true
		_quality_spice_chance = 0


func _try_random_walk(id: int) -> bool:
	var x: int = _self_pos.x
	var y: int = _self_pos.y
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(x, y, 1)
	var candidate: Array = []
	var neck: Game_IntCoord
	var coord: Game_IntCoord
	var move_to: Game_IntCoord
	var pc: Sprite = _ref_DungeonBoard.get_pc()

	if _id_to_worm[id][1] != null:
		neck = Game_ConvertCoord.vector_to_coord(_id_to_worm[id][1].position)
		coord = Game_CoordCalculator.get_mirror_image(neck.x, neck.y, x, y)
		if Game_CoordCalculator.is_inside_dungeon(coord.x, coord.y):
			neighbor.push_back(coord)

	for i in neighbor:
		if _ref_DungeonBoard.has_actor_xy(i.x, i.y) and (not _is_pc_pos(
				i.x, i.y)):
			continue
		candidate.push_back(i)

	if candidate.size() < 1:
		return false
	move_to = candidate[_ref_RandomNumber.get_int(0, candidate.size())]

	if _is_pc_pos(move_to.x, move_to.y):
		_ref_SwitchSprite.set_sprite(pc, Game_SpriteTypeTag.ACTIVE)
		_ref_SwitchSprite.set_sprite(_self, Game_SpriteTypeTag.ACTIVE)
		_ref_EndGame.player_lose()
		return false

	_ref_RemoveObject.remove_building(move_to.x, move_to.y)
	_ref_RemoveObject.remove_trap(move_to.x, move_to.y)

	_set_danger_zone(_self, false)
	_ref_DungeonBoard.move_actor_xy(_self_pos.x, _self_pos.y,
			move_to.x, move_to.y)
	_set_danger_zone(_self, true)
	return true


func _is_pc_pos(x: int, y: int) -> bool:
	return (x == _pc_pos.x) and (y == _pc_pos.y)


func _move_body(id: int) -> void:
	var worm: Array = _id_to_worm[id]
	var current_position: Game_IntCoord = _self_pos
	var save_position: Game_IntCoord

	for i in range(1, worm.size()):
		if worm[i] == null:
			_create_body(id, i, current_position.x, current_position.y)
			return

		save_position = Game_ConvertCoord.vector_to_coord(worm[i].position)
		_ref_DungeonBoard.move_actor_xy(save_position.x, save_position.y,
				current_position.x, current_position.y)
		current_position = save_position


func _bury_worm(id: int) -> void:
	var worm: Array = _id_to_worm[id]
	var create_spice: int = Game_DesertData.CREATE_SPICE
	var pos: Game_IntCoord

	for i in range(Game_DesertData.SPICE_END):
		if worm[i] == null:
			break
		if _has_spice(worm[i]) and (not _is_passive_spice(worm[i])):
			create_spice += Game_DesertData.BONUS_CREATE_SPICE

	for i in worm:
		if i == null:
			break
		pos = Game_ConvertCoord.vector_to_coord(i.position)
		_ref_RemoveObject.remove_actor(pos.x, pos.y)
		if _ref_RandomNumber.get_percent_chance(create_spice):
			_ref_CreateObject.create_trap(_spr_Treasure, Game_SubTag.TREASURE,
					pos.x, pos.y)
		else:
			_ref_CreateObject.create_building(_spr_Wall, Game_SubTag.WALL,
					pos.x, pos.y)

	_clear_worm_data(id)
	_quality_spice_chance += Game_DesertData.CREATE_QUALITY_SPICE


func _can_bury_worm(id: int) -> bool:
	var worm: Array = _id_to_worm[id]
	var hit_point: int = _ref_ObjectData.get_hit_point(worm[0])

	for i in worm:
		if i == null:
			break
		if _has_spice(i) and _is_passive_spice(i):
			hit_point -= Game_DesertData.HP_SPICE
	return hit_point > Game_DesertData.HP_BURY


func _set_danger_zone(head: Sprite, is_danger: bool) -> void:
	var pos := Game_ConvertCoord.vector_to_coord(head.position)
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(pos.x, pos.y, 1)

	for i in neighbor:
		_ref_DangerZone.set_danger_zone(i.x, i.y, is_danger)


func _is_passive_spice(spice: Sprite) -> bool:
	return _ref_ObjectData.verify_state(spice, Game_StateTag.PASSIVE)


func _has_spice(body: Sprite) -> bool:
	return body.is_in_group(Game_SubTag.WORM_SPICE)


func _clear_worm_data(id: int) -> void:
	var __
	__ = _id_to_worm.erase(id)
	__ = _id_to_has_active_spice.erase(id)
