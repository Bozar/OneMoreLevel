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


func end_world(_pc_x: int, _pc_y: int) -> void:
	var count_captain: int
	var count_boss: int
	var count_knight: int

	if _spawn_captain:
		for _i in range(Game_KnightData.MAX_CAPTAIN - 1):
			_spawn_npc(Game_SubTag.KNIGHT_CAPTAIN)
		_spawn_captain = false
	elif _spawn_boss:
		_spawn_npc(Game_SubTag.KNIGHT_BOSS)
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
		_spawn_npc(Game_SubTag.KNIGHT)


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


func _spawn_npc(sub_tag: String) -> void:
	var new_actor: PackedScene
	var grids: Array

	match sub_tag:
		Game_SubTag.KNIGHT:
			new_actor = _spr_Knight
		Game_SubTag.KNIGHT_CAPTAIN:
			new_actor = _spr_KnightCaptain
		Game_SubTag.KNIGHT_BOSS:
			new_actor = _spr_KnightBoss

	_init_dungeon_grids()
	_mark_buildings()
	_mark_actors()
	grids = _get_unoccupied_grids()

	if grids.size() == 0:
		print("No available respawn point.")
		return
	Game_ArrayHelper.rand_picker(grids, 1, _ref_RandomNumber)
	_ref_CreateObject.create_actor(new_actor, sub_tag, grids[0])


func _mark_buildings() -> void:
	for x in range(0, Game_DungeonSize.MAX_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_building_xy(x, y):
				DUNGEON_GRIDS[x][y] = true
			else:
				DUNGEON_GRIDS[x][y] = false


func _mark_actors() -> void:
	var pos: Game_IntCoord
	var min_gap: int
	var neighbor: Array

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.ACTOR):
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if i.is_in_group(Game_SubTag.PC):
			min_gap = Game_KnightData.RENDER_RANGE
		else:
			min_gap = Game_KnightData.KNIGHT_GAP
		neighbor = Game_CoordCalculator.get_neighbor(pos, min_gap, true)
		for j in neighbor:
			DUNGEON_GRIDS[j.x][j.y] = true


func _get_unoccupied_grids() -> Array:
	var grids := []

	for x in range(0, Game_DungeonSize.MAX_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if DUNGEON_GRIDS[x][y]:
				continue
			grids.push_back(Game_IntCoord.new(x, y))
	return grids
