extends Game_ProgressTemplate


var _spr_Bird := preload("res://sprite/Bird.tscn")

var _tree_grids := []
# var _test_once := true


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(_pc_coord: Game_IntCoord) -> void:
	_respawn_bird()

	# if _test_once:
	# 	_test_spawn_bandits(_pc_x, _pc_y)
	# 	_test_once = false


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if actor.is_in_group(Game_SubTag.BANDIT):
		_mark_tree_trunk()


func create_actor(actor: Sprite, sub_tag: String, x: int, y: int) -> void:
	if sub_tag != Game_SubTag.BIRD:
		return

	if  _ref_DungeonBoard.has_sprite_with_sub_tag_xy(Game_MainTag.BUILDING,
			Game_SubTag.TREE_BRANCH, x, y):
		_ref_SwitchSprite.set_sprite(actor, Game_SpriteTypeTag.ACTIVE)


# !!!IMPORTANT NOTE: Beware of an infinite loop.!!!
#
# The code snippet below has a bug that had troubled me for about 6 hours. When
# removing too many bandits who are close to each other in one turn,
# Game_CoordCalculator.get_neighbor() cannot find enough candidates and results
# in an infinite loop.
#
# Steps to locate the source of the problem and solve it.
#
# 1. Find a seed that can easily reproduce the problem. Write helper functions
# to make the problem more severe.
#
# 2. Try to locate which part (or parts) cause the problem. I noticed that
# commenting out BaronAI._approach_pc() or BaronPCAction.remove_actor() solves
# the problem. I have also tried do not create birds or trees at all.
#
# 3. Check each function itself (how does pathfinding work) and its releated
# parts (who receives the removing signal) carefully. I cannot find anything
# wrong in pathfinding, however there is a suspicious loop in BaronProgress,
# which is triggered when an actor is removed.

# func _mark_tree_trunk(x: int, y: int) -> void:
# 	var neighbor := Game_CoordCalculator.get_neighbor_xy(x, y,
# 			Game_BaronData.FAR_SIGHT)
# 	var building: Sprite
#
# 	Game_ArrayHelper.shuffle(neighbor, _ref_RandomNumber)
# 	for i in neighbor:
# 		building = _ref_DungeonBoard.get_building_xy(i.x, i.y)
# 		if (building == null) \
# 				or building.is_in_group(Game_SubTag.TREE_BRANCH) \
# 				or building.is_in_group(Game_SubTag.COUNTER):
# 			continue
# 		_ref_SwitchSprite.set_sprite(building, Game_SpriteTypeTag.ACTIVE)
# 		building.add_to_group(Game_SubTag.COUNTER)
# 		_ref_RemoveObject.remove_actor_xy(i.x, i.y, Game_BaronData.TREE_LAYER)
# 		break


func _mark_tree_trunk() -> void:
	var trunks := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.TREE_TRUNK)
	var pos: Game_IntCoord

	Game_ArrayHelper.rand_picker(trunks, Game_BaronData.MAX_BANDIT,
			_ref_RandomNumber)
	for i in trunks:
		# Mark a tree trunk.
		if i.is_in_group(Game_SubTag.COUNTER):
			continue
		_ref_SwitchSprite.set_sprite(i, Game_SpriteTypeTag.ACTIVE)
		i.add_to_group(Game_SubTag.COUNTER)
		# Drive away the bird if there is any.
		pos = Game_ConvertCoord.sprite_to_coord(i)
		if _ref_DungeonBoard.has_sprite_with_sub_tag(Game_MainTag.ACTOR,
				Game_SubTag.BIRD, pos, Game_BaronData.TREE_LAYER):
			_ref_RemoveObject.remove_actor(pos, Game_BaronData.TREE_LAYER)
		break


func _respawn_bird() -> void:
	var birds := _ref_DungeonBoard.get_sprites_by_tag(Game_SubTag.BIRD)
	var count_bird := birds.size()
	var trees: Array
	var pos: Game_IntCoord
	var has_neighbor: bool

	# PC has seen all the birds. Refer: BaronAI._bird_act().
	for i in birds:
		_ref_ObjectData.set_bool(i, true)
	# Do not respawn if there are enough birds.
	if count_bird >= Game_BaronData.MAX_BIRD:
		return

	trees = _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.BUILDING)
	Game_ArrayHelper.shuffle(trees, _ref_RandomNumber)
	for i in trees:
		# There are enough birds.
		if count_bird >= Game_BaronData.MAX_BIRD:
			break
		# Current grid has a marked tree trunk or a bird.
		pos = Game_ConvertCoord.sprite_to_coord(i)
		has_neighbor = false
		if i.is_in_group(Game_SubTag.COUNTER) \
				or _ref_DungeonBoard.has_actor(pos, Game_BaronData.TREE_LAYER):
			continue
		# Current grid is close to other birds.
		for j in Game_CoordCalculator.get_neighbor(pos,
				Game_BaronData.MIN_BIRD_GAP):
			if _ref_DungeonBoard.has_actor(j, Game_BaronData.TREE_LAYER):
				has_neighbor = true
				break
		if has_neighbor:
			continue
		# Create a new bird here.
		_ref_CreateObject.create_actor(_spr_Bird, Game_SubTag.BIRD, pos,
				Game_BaronData.TREE_LAYER)
		count_bird += 1


# func _test_spawn_bandits(x: int, y: int) -> void:
# 	var actor: Sprite
# 	var _spr_Bandit := preload("res://sprite/Bandit.tscn")
# 	var spawn_range := 3

# 	for i in Game_CoordCalculator.get_neighbor_xy(x, y, spawn_range):
# 		if not (_ref_DungeonBoard.has_sprite_with_sub_tag(
# 				Game_SubTag.TREE_TRUNK, i) \
# 				or _ref_DungeonBoard.has_actor(i)):
# 			actor = _ref_CreateObject.create_and_fetch_actor(_spr_Bandit,
# 					Game_SubTag.BANDIT, i)
# 			_ref_ObjectData.set_hit_point(actor, Game_BaronData.MAX_HP - 1)
