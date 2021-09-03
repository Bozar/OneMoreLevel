extends Game_ProgressTemplate


const MAX_RETRY: int = 99

var _spr_Devil := preload("res://sprite/Devil.tscn")

var _alive_npc: int = Game_RailgunData.MAX_NPC


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	if Game_RailgunData.MAX_NPC - _alive_npc < Game_RailgunData.TRIGGER_RESPAWN:
		return
	for _i in range(Game_RailgunData.TRIGGER_RESPAWN):
		_respawn_npc(pc_x, pc_y)


func remove_actor(_actor: Sprite, _x: int, _y: int) -> void:
	_alive_npc -= 1
	_alive_npc = max(_alive_npc, 0) as int


func _respawn_npc(pc_x: int, pc_y: int) -> void:
	var x: int
	var y: int
	var neighbor: Array
	var has_neighbor: bool
	var is_valid_coord: bool = false

	for _i in range(MAX_RETRY):
		x = _ref_RandomNumber.get_x_coord()
		y = _ref_RandomNumber.get_y_coord()

		if _ref_DungeonBoard.has_building(x, y):
			continue
		elif Game_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				Game_RailgunData.PC_FRONT_SIGHT):
			continue
		else:
			neighbor = Game_CoordCalculator.get_neighbor(x, y,
					Game_RailgunData.NPC_GAP, true)
			has_neighbor = false
			for i in neighbor:
				if _ref_DungeonBoard.has_actor(i[0], i[1]):
					has_neighbor = true
					break
			if has_neighbor:
				continue
		is_valid_coord = true
		break

	if is_valid_coord:
		_ref_RemoveObject.remove_trap(x, y)
		_ref_CreateObject.create_actor(_spr_Devil, Game_SubTag.DEVIL, x, y)
		_alive_npc += 1
