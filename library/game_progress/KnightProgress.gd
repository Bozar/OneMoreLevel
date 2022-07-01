extends Game_ProgressTemplate


const SWITCH_NUMBER := [
	Game_SpriteTypeTag.ONE,
	Game_SpriteTypeTag.TWO,
	Game_SpriteTypeTag.THREE,
]

var _spr_Knight := preload("res://sprite/Knight.tscn")
var _spr_KnightCaptain := preload("res://sprite/KnightCaptain.tscn")
var _spr_KnightBoss := preload("res://sprite/KnightBoss.tscn")

var _dead_captain := 0
var _spawn_captain := false
var _spawn_boss := false
var _spawn_knight := false
var _counter: Sprite


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	var count_captain: int
	var count_boss: int
	var count_knight: int

	if _spawn_captain:
		for _i in range(Game_KnightData.MAX_CAPTAIN - 1):
			_spawn_npc(Game_SubTag.KNIGHT_CAPTAIN, pc_x, pc_y)
		_spawn_captain = false
	elif _spawn_boss:
		_spawn_npc(Game_SubTag.KNIGHT_BOSS, pc_x, pc_y)
		_spawn_boss = false

	count_captain = _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.KNIGHT_CAPTAIN).size()
	count_boss = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.KNIGHT_BOSS) \
			.size()
	count_knight = _ref_DungeonBoard.count_npc() - count_captain - count_boss

	if count_knight == Game_KnightData.MAX_KNIGHT:
		_spawn_knight = false
	elif count_knight < Game_KnightData.START_RESPAWN:
		_spawn_knight = true
	if _spawn_knight:
		_spawn_npc(Game_SubTag.KNIGHT, pc_x, pc_y)


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(Game_SubTag.KNIGHT_CAPTAIN):
		return

	_dead_captain += 1
	if _dead_captain == 1:
		_spawn_captain = true
		_spawn_boss = false
	elif _dead_captain == Game_KnightData.MAX_CAPTAIN:
		_spawn_captain = false
		_spawn_boss = true

	if _counter == null:
		_counter = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.COUNTER)[0]
	_ref_SwitchSprite.set_sprite(_counter, SWITCH_NUMBER[_dead_captain - 1])


func _spawn_npc(sub_tag: String, pc_x: int, pc_y: int) -> void:
	var new_actor: PackedScene
	var x: int
	var y: int

	match sub_tag:
		Game_SubTag.KNIGHT:
			new_actor = _spr_Knight
		Game_SubTag.KNIGHT_CAPTAIN:
			new_actor = _spr_KnightCaptain
		Game_SubTag.KNIGHT_BOSS:
			new_actor = _spr_KnightBoss

	while true:
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()
		if _is_occupied(x, y) \
				or _is_close_to_pc(x, y, pc_x, pc_y) \
				or _has_neighbor(x, y):
			continue
		break
	_ref_CreateObject.create_actor_xy(new_actor, sub_tag, x, y)


func _is_occupied(x: int, y: int) -> bool:
	return _ref_DungeonBoard.has_actor_xy(x, y) \
			or _ref_DungeonBoard.has_building_xy(x, y)


func _is_close_to_pc(self_x: int, self_y: int, pc_x: int, pc_y: int) -> bool:
	return Game_CoordCalculator.is_in_range_xy(self_x, self_y, pc_x, pc_y,
			Game_KnightData.RENDER_RANGE)


func _has_neighbor(x: int, y: int) -> bool:
	var neighbor: Array = Game_CoordCalculator.get_neighbor_xy(x, y,
			Game_KnightData.KNIGHT_GAP)

	for i in neighbor:
		if _ref_DungeonBoard.has_actor_xy(i.x, i.y):
			return true
	return false
