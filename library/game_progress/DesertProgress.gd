extends Game_ProgressTemplate


const MAX_RETRY := 0
const MAX_CANDIDATES := 10
const DETECT_RANGE := 3

var _spr_WormHead := preload("res://sprite/WormHead.tscn")
var _spr_Counter := preload("res://sprite/Counter.tscn")

var _respawn_counter := []
var _all_coords := []
var _count_worms := 0


func _init(parent_node: Node2D).(parent_node) -> void:
	Game_WorldGenerator.init_array(_respawn_counter, Game_DesertData.MAX_WORM,
			Game_DesertData.MIN_COOLDOWN)
	Game_DungeonSize.init_all_coords(_all_coords)


func start_first_turn() -> void:
	_try_add_new_worm(false)


func renew_world(pc_x: int, pc_y: int) -> void:
	# Count adjacent worms at the start of PC's turn.
	_count_worms = _get_adjacent_worms(pc_x, pc_y)


func end_world(_pc_x: int, _pc_y: int) -> void:
	var count := _count_worms * Game_DesertData.SANDWORM_CONSUME_TURN

	# Do not subtract count if game ends.
	_ref_CountDown.subtract_count(count)
	_try_add_new_worm(true)


func remove_actor(actor: Sprite, _x: int, _y: int) -> void:
	if not actor.is_in_group(Game_SubTag.WORM_HEAD):
		return

	for i in range(0, _respawn_counter.size()):
		# Reset at most one counter when removing a sandworm.
		if _respawn_counter[i] < Game_DesertData.MIN_COOLDOWN:
			_respawn_counter[i] = _ref_RandomNumber.get_int(
					Game_DesertData.MIN_COOLDOWN, Game_DesertData.MAX_COOLDOWN)
			break


func _try_add_new_worm(is_passive: bool) -> void:
	for i in range(_respawn_counter.size()):
		# A sandworm has already been created.
		if _respawn_counter[i] < Game_DesertData.MIN_COOLDOWN:
			continue
		elif _respawn_counter[i] == Game_DesertData.MIN_COOLDOWN:
			# Retry next turn.
			if not _create_worm_head(is_passive):
				_respawn_counter[i] += 1
		# Keep waiting.
		_respawn_counter[i] -= 1


func _create_worm_head(is_passive: bool) -> bool:
	var actor_coords := []
	var worm_coords := []
	var this_coord: Game_IntCoord
	var head: Sprite

	for i in _ref_DungeonBoard.get_sprites_by_tag(Game_MainTag.ACTOR):
		actor_coords.push_back(Game_ConvertCoord.sprite_to_coord(i))
	Game_WorldGenerator.create_by_coord(_all_coords,
			MAX_CANDIDATES, _ref_RandomNumber, self,
			"_is_valid_worm_coord", [actor_coords],
			"_create_worm_here", [worm_coords], MAX_RETRY)
	if worm_coords.size() < 1:
		return false

	worm_coords.sort_custom(self, "_sort_by_floor")
	this_coord = worm_coords.pop_back()

	_ref_RemoveObject.remove_building(this_coord)
	_ref_RemoveObject.remove_trap(this_coord)
	head = _ref_CreateObject.create_and_fetch_actor(_spr_WormHead,
			Game_SubTag.WORM_HEAD, this_coord)
	if is_passive:
		_ref_ObjectData.set_state(head, Game_StateTag.PASSIVE)
	return true


func _has_building_or_trap(coord: Game_IntCoord) -> bool:
	return _ref_DungeonBoard.has_building(coord) \
			or _ref_DungeonBoard.has_trap(coord)


func _is_valid_worm_coord(coord: Game_IntCoord, _retry: int, opt_arg: Array) \
		-> bool:
	var actor_coords: Array = opt_arg[0]

	for i in actor_coords:
		if Game_CoordCalculator.is_in_range(i, coord,
				Game_DesertData.WORM_DISTANCE):
			return false
	return true


func _create_worm_here(coord: Game_IntCoord, opt_arg: Array) -> void:
	var worm_coords: Array = opt_arg[0]
	worm_coords.push_back(coord)


func _sort_by_floor(l_coord: Game_IntCoord, r_coord: Game_IntCoord) -> bool:
	return _get_unoccupied_floor(l_coord) < _get_unoccupied_floor(r_coord)


func _get_unoccupied_floor(coord: Game_IntCoord) -> int:
	var unoccupied := 0

	for i in Game_CoordCalculator.get_neighbor(coord, DETECT_RANGE, true):
		if not _has_building_or_trap(i):
			unoccupied += 1
	return unoccupied


func _get_adjacent_worms(pc_x: int, pc_y: int) -> int:
	var worms := 0

	for i in Game_CoordCalculator.get_neighbor_xy(pc_x, pc_y, 1):
		if _ref_DungeonBoard.has_actor(i):
			worms += 1
	return worms
