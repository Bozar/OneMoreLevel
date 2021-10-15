extends Game_ProgressTemplate


var _spr_Hound := preload("res://sprite/Hound.tscn")
var _spr_HoundBoss := preload("res://sprite/HoundBoss.tscn")

var _fog_source: Array = []
var _all_grounds: Array = []
var _current_hound: int = Game_HoundData.MAX_HOUND
var _minion_trigger: bool = false
var _boss_trigger: bool = true
var _boss_hit_point: int = 0
var _all_counters: Array = []


func _init(parent_node: Node2D).(parent_node) -> void:
	# _fog_source = [[3, 3, 0]]
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	_respawn_boss(pc_x, pc_y)
	_respawn_minion(pc_x, pc_y)
	_add_or_remove_fog()


func create_actor(actor: Sprite, sub_tag: String, _x: int, _y: int) -> void:
	if sub_tag != Game_SubTag.HOUND_BOSS:
		return

	_ref_ObjectData.set_hit_point(actor, _boss_hit_point)

	if _all_counters.size() == 0:
		_all_counters = _ref_DungeonBoard.get_sprites_by_tag(
				Game_SubTag.COUNTER)
		Game_ArrayHelper.shuffle(_all_counters, _ref_RandomNumber)
	_ref_SwitchSprite.set_sprite(_all_counters[_boss_hit_point],
			Game_SpriteTypeTag.PASSIVE)


func remove_actor(actor: Sprite, x: int, y: int) -> void:
	if actor.is_in_group(Game_SubTag.HOUND):
		_fog_source.push_back([x, y, Game_HoundData.MIN_FOG_SIZE])
		_current_hound -= 1
		if _current_hound <= Game_HoundData.START_RESPAWN:
			_minion_trigger = true
	elif actor.is_in_group(Game_SubTag.HOUND_BOSS):
		_boss_trigger = true
		# The boss is hit by PC.
		# HoundPCAction._try_set_and_get_boss_hit_point().
		if _ref_ObjectData.get_hit_point(actor) > _boss_hit_point:
			_ref_SwitchSprite.set_sprite(_all_counters[_boss_hit_point],
					Game_SpriteTypeTag.ACTIVE)
			_boss_hit_point = _ref_ObjectData.get_hit_point(actor)
		# The boss is removed due to running out of time.
		# HoundAI._boss_countdown().
		else:
			_boss_hit_point += 1


func _add_or_remove_fog() -> void:
	var x: int
	var y: int
	var fog_range: int
	var remove_index: Array = []
	var neighbor: Array
	var ground: Sprite

	for i in range(_fog_source.size()):
		x = _fog_source[i][0]
		y = _fog_source[i][1]
		fog_range = _fog_source[i][2]
		if fog_range < Game_HoundData.MAX_FOG_SIZE:
			_fog_source[i][2] += 1
			neighbor = Game_CoordCalculator.get_neighbor(x, y, fog_range, true)
			for j in neighbor:
				ground = _ref_DungeonBoard.get_ground(j.x, j.y)
				if ground != null:
					_ref_ObjectData.add_hit_point(ground,
							Game_HoundData.FOG_DURATION)
		else:
			remove_index.push_back(i)

	for i in remove_index:
		Game_ArrayHelper.remove_by_index(_fog_source, i)

	if _all_grounds.size() == 0:
		_all_grounds = _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.GROUND)
	for i in _all_grounds:
		if _ref_ObjectData.get_hit_point(i) > 0:
			_ref_ObjectData.subtract_hit_point(i, 1)
			_set_ground_state(i, true)
		else:
			_ref_ObjectData.set_hit_point(i, 0)
			_set_ground_state(i, false)


func _set_ground_state(ground: Sprite, is_active: bool) -> void:
	var new_sprite_type: String

	if is_active:
		_ref_ObjectData.set_state(ground, Game_StateTag.ACTIVE)
		if _ref_ObjectData.get_hit_point(ground) == 0:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE_1
		else:
			new_sprite_type = Game_SpriteTypeTag.ACTIVE
	else:
		_ref_ObjectData.set_state(ground, Game_StateTag.DEFAULT)
		new_sprite_type = Game_SpriteTypeTag.DEFAULT
	_ref_SwitchSprite.set_sprite(ground, new_sprite_type)


func _respawn_minion(pc_x: int, pc_y: int) -> void:
	# Once respawn is started, keep adding 1 hound every turn until there are 10
	# hounds.
	if _current_hound == Game_HoundData.MAX_HOUND:
		_minion_trigger = false
	if not _minion_trigger:
		return

	_current_hound += 1
	_respawn_actor(pc_x, pc_y,
			Game_HoundData.MIN_MINION_DISTANCE,
			Game_HoundData.MAX_MINION_DISTANCE,
			_spr_Hound, Game_SubTag.HOUND)


func _respawn_boss(pc_x: int, pc_y: int) -> void:
	if (not _boss_trigger) or (_current_hound < Game_HoundData.MAX_HOUND):
		return

	_boss_trigger = false
	_respawn_actor(pc_x, pc_y,
			Game_HoundData.MIN_BOSS_DISTANCE,
			Game_HoundData.MAX_BOSS_DISTANCE,
			_spr_HoundBoss, Game_SubTag.HOUND_BOSS)


func _respawn_actor(pc_x: int, pc_y: int, min_distance: int, max_distance: int,
		new_sprite: PackedScene, sub_tag: String) -> void:
	var x: int
	var y: int
	var neighbor: Array
	var next_loop: bool

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		next_loop = false
		if _ref_DungeonBoard.has_building(x, y):
			next_loop = true
		elif _ref_DungeonBoard.has_actor(x, y):
			next_loop = true
		elif Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				min_distance):
			next_loop = true
		elif not Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				max_distance):
			next_loop = true
		else:
			neighbor = Game_CoordCalculator.get_neighbor(x, y,
					Game_HoundData.MIN_HOUND_GAP)
			for i in neighbor:
				if _ref_DungeonBoard.has_actor(i.x, i.y):
					next_loop = true
					break
		if not next_loop:
			break
	_ref_CreateObject.create_actor(new_sprite, sub_tag, x, y)
