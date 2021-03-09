extends "res://library/game_progress/ProgressTemplate.gd"


const MAX_RETRY: int = 99

var _spr_Demon := preload("res://sprite/Demon.tscn")

var _new_RailgunData := preload("res://library/npc_data/RailgunData.gd").new()

var _alive_npc: int = _new_RailgunData.MAX_NPC


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func end_world(pc_x: int, pc_y: int) -> void:
	if _new_RailgunData.MAX_NPC - _alive_npc < _new_RailgunData.TRIGGER_RESPAWN:
		return
	for _i in range(_new_RailgunData.TRIGGER_RESPAWN):
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

		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING, x, y):
			continue
		elif _new_CoordCalculator.is_inside_range(x, y, pc_x, pc_y,
				_new_RailgunData.PC_FRONT_SIGHT):
			continue
		else:
			neighbor = _new_CoordCalculator.get_neighbor(x, y,
					_new_RailgunData.NPC_GAP, true)
			has_neighbor = false
			for i in neighbor:
				if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.ACTOR,
						i[0], i[1]):
					has_neighbor = true
					break
			if has_neighbor:
				continue
		is_valid_coord = true
		break

	if is_valid_coord:
		if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP, x, y):
			_ref_RemoveObject.remove(_new_MainGroupTag.TRAP, x, y)
		_ref_CreateObject.create(_spr_Demon,
				_new_MainGroupTag.ACTOR, _new_SubGroupTag.DEMON, x, y)
		_alive_npc += 1
