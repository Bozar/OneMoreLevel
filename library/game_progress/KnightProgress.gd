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
var _count_new_captain := 0
var _spawn_captain := false
var _spawn_boss := false
var _spawn_knight := false
var _counter: Sprite
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_coord: Game_IntCoord) -> void:
	var count_knight := _ref_DungeonBoard.get_sprites_by_tag(
			Game_SubTag.KNIGHT).size()
	var __

	if _ground_coords.size() < 1:
		for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.GROUND):
			_ground_coords.push_back(Game_ConvertCoord.sprite_to_coord(i))

	if _spawn_captain:
		if _count_new_captain == Game_KnightData.MAX_CAPTAIN - 1:
			_spawn_captain = false
		elif _spawn_npc(Game_SubTag.KNIGHT_CAPTAIN):
			_count_new_captain += 1
	elif _spawn_boss:
		_spawn_boss = not _spawn_npc(Game_SubTag.KNIGHT_BOSS)

	if count_knight == Game_KnightData.MAX_KNIGHT:
		_spawn_knight = false
	elif count_knight < Game_KnightData.START_RESPAWN:
		_spawn_knight = true
	if _spawn_knight:
		__ = _spawn_npc(Game_SubTag.KNIGHT)


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(Game_SubTag.KNIGHT_CAPTAIN):
		return

	_dead_captain += 1
	if _dead_captain == 1:
		_spawn_captain = true
	elif _dead_captain == Game_KnightData.MAX_CAPTAIN:
		_spawn_boss = true

	if _counter == null:
		_counter = _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.COUNTER)[0]
	_ref_SwitchSprite.set_sprite(_counter, SWITCH_NUMBER[_dead_captain - 1])


func _spawn_npc(sub_tag: String) -> bool:
	var new_actor: PackedScene

	match sub_tag:
		Game_SubTag.KNIGHT:
			new_actor = _spr_Knight
		Game_SubTag.KNIGHT_CAPTAIN:
			new_actor = _spr_KnightCaptain
		Game_SubTag.KNIGHT_BOSS:
			new_actor = _spr_KnightBoss
		_:
			return false

	Game_ArrayHelper.shuffle(_ground_coords, _ref_RandomNumber)
	for i in _ground_coords:
		if _is_close_to_pc(i) or _is_close_to_knight(i):
			continue
		_ref_CreateObject.create_actor(new_actor, sub_tag, i)
		return true
	return false


func _is_close_to_pc(coord: Game_IntCoord) -> bool:
	var pc_pos := Game_ConvertCoord.sprite_to_coord(_ref_DungeonBoard.get_pc())
	return Game_CoordCalculator.is_in_range(coord, pc_pos,
			Game_KnightData.RENDER_RANGE)


func _is_close_to_knight(coord: Game_IntCoord) -> bool:
	var pos: Game_IntCoord

	for i in _ref_DungeonBoard.get_npc():
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if Game_CoordCalculator.is_in_range(pos, coord,
				Game_KnightData.KNIGHT_GAP):
			return true
	return false
