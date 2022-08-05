extends Game_ProgressTemplate


const MAX_RETRY := 1

var _spr_Devil := preload("res://sprite/Devil.tscn")

var _alive_npc := 0
var _ground_coords := []


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func start_first_turn(pc_coord: Game_IntCoord) -> void:
	_init_ground_coords()
	_respawn_npc(pc_coord)


func end_world(pc_coord: Game_IntCoord) -> void:
	if Game_RailgunData.MAX_NPC - _alive_npc < Game_RailgunData.TRIGGER_RESPAWN:
		return
	_respawn_npc(pc_coord)


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	_alive_npc -= 1
	_alive_npc = max(_alive_npc, 0) as int


func _init_ground_coords() -> void:
	for x in range(0, Game_DungeonSize.MAX_X):
		for y in range(0, Game_DungeonSize.MAX_Y):
			if _ref_DungeonBoard.has_building_xy(x, y):
				continue
			_ground_coords.push_back(Game_IntCoord.new(x, y))


func _respawn_npc(pc_coord: Game_IntCoord) -> void:
	Game_WorldGenerator.create_by_coord(_ground_coords,
			Game_RailgunData.TRIGGER_RESPAWN, _ref_RandomNumber, self,
			"_is_valid_devil_coord", [pc_coord],
			"_create_devil_here", [], MAX_RETRY)


func _is_valid_devil_coord(coord: Game_IntCoord, retry: int, opt_arg: Array) \
		-> bool:
	var pc_coord: Game_IntCoord = opt_arg[0]
	var npc_coord: Game_IntCoord

	if Game_CoordCalculator.is_in_range(coord, pc_coord,
			Game_RailgunData.PC_FRONT_SIGHT):
		return false
	elif Game_CoordCalculator.is_out_of_range(coord, pc_coord,
			Game_RailgunData.MAX_DISTANCE_TO_PC):
		return false
	elif retry > 0:
		return not _ref_DungeonBoard.has_actor(coord)
	else:
		for i in _ref_DungeonBoard.get_npc():
			npc_coord = Game_ConvertCoord.sprite_to_coord(i)
			if Game_CoordCalculator.is_in_range(coord, npc_coord,
					Game_RailgunData.NPC_GAP):
				return false
	return true


func _create_devil_here(coord: Game_IntCoord, _opt: Array) -> void:
	_ref_RemoveObject.remove_trap(coord)
	_ref_CreateObject.create_actor(_spr_Devil, Game_SubTag.DEVIL, coord)
	_alive_npc += 1
