extends Game_ProgressTemplate


var _spr_Hound := preload("res://sprite/Hound.tscn")
var _spr_HoundBoss := preload("res://sprite/HoundBoss.tscn")

var _fog_source := []
var _ground_sprites := []
var _ground_coords := []
var _current_hound := Game_HoundData.MAX_HOUND
var _minion_trigger := false


func _init(parent_node: Node2D).(parent_node) -> void:
	# _fog_source = [[3, 3, 0]]
	pass


func start_first_turn() -> void:
	var pos := Game_ConvertCoord.sprite_to_coord(_ref_DungeonBoard.get_pc())

	_init_grounds()
	_respawn_boss(pos.x, pos.y)


func end_world(pc_x: int, pc_y: int) -> void:
	_respawn_minion(pc_x, pc_y)
	_add_or_remove_fog()


func remove_actor(actor: Sprite, x: int, y: int) -> void:
	if not actor.is_in_group(Game_SubTag.HOUND):
		return

	_fog_source.push_back([x, y, Game_HoundData.MIN_FOG_SIZE])
	_current_hound -= 1
	if _current_hound <= Game_HoundData.START_RESPAWN:
		_minion_trigger = true


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
			neighbor = Game_CoordCalculator.get_neighbor_xy(x, y, fog_range,
					true)
			for j in neighbor:
				ground = _ref_DungeonBoard.get_ground_xy(j.x, j.y)
				if ground != null:
					_ref_ObjectData.add_hit_point(ground,
							Game_HoundData.FOG_DURATION)
		else:
			remove_index.push_back(i)

	for i in remove_index:
		Game_ArrayHelper.remove_by_index(_fog_source, i)

	for i in _ground_sprites:
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
	_respawn_actor(pc_x, pc_y,
			Game_HoundData.MIN_BOSS_DISTANCE,
			Game_HoundData.MAX_BOSS_DISTANCE,
			_spr_HoundBoss, Game_SubTag.HOUND_BOSS)


func _respawn_actor(pc_x: int, pc_y: int, min_range: int, max_range: int,
		new_sprite: PackedScene, sub_tag: String) -> void:
	var pc_pos := Game_IntCoord.new(pc_x, pc_y)

	Game_ArrayHelper.shuffle(_ground_coords, _ref_RandomNumber)
	for i in _ground_coords:
		if Game_CoordCalculator.is_in_range(i, pc_pos, min_range) \
				or Game_CoordCalculator.is_out_of_range(i, pc_pos, max_range) \
				or _is_close_to_hound(i):
			continue
		_ref_CreateObject.create_actor(new_sprite, sub_tag, i)
		break


func _is_close_to_hound(coord: Game_IntCoord) -> bool:
	var this_npc: Game_IntCoord

	for i in _ref_DungeonBoard.get_npc():
		this_npc = Game_ConvertCoord.sprite_to_coord(i)
		if Game_CoordCalculator.is_in_range(coord, this_npc,
				Game_HoundData.MIN_HOUND_GAP):
			return true
	return false


func _init_grounds() -> void:
	_ground_sprites = _ref_DungeonBoard.get_sprites_by_tag(
			Game_MainTag.GROUND)
	for i in _ground_sprites:
		_ground_coords.push_back(Game_ConvertCoord.sprite_to_coord(i))
