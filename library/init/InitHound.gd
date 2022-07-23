extends Game_WorldTemplate


const ROOM_SIZE := 4
const CORRIDOR_WIDTH := 1
const PICK_ROOM := 11
const MIN_X := 1
const MIN_Y := 0
const MIN_SHIFT := 1
const MAX_SHIFT := 3

var _spr_FloorHound := preload("res://sprite/FloorHound.tscn")
var _spr_PCHound := preload("res://sprite/PCHound.tscn")
var _spr_WallHound := preload("res://sprite/WallHound.tscn")
var _spr_Hound := preload("res://sprite/Hound.tscn")
# var _spr_HoundBoss := preload("res://sprite/HoundBoss.tscn")


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_create_wall()
	_init_floor(_spr_FloorHound)
	_create_pc()
	_init_actor(Game_HoundData.MIN_HOUND_GAP, INVALID_COORD, INVALID_COORD,
			Game_HoundData.MAX_HOUND, _spr_Hound, Game_SubTag.HOUND)
	# _init_actor(1, INVALID_COORD, INVALID_COORD,
	# 		1, _spr_HoundBoss, Game_SubTag.HOUND_BOSS)

	return _blueprint


func _create_wall() -> void:
	var counter_index: int = _ref_RandomNumber.get_int(0, PICK_ROOM)
	var start_point: Array = _get_top_left_position()
	var x: int
	var y: int
	var neighbor: Array

	Game_ArrayHelper.rand_picker(start_point, PICK_ROOM, _ref_RandomNumber)
	for i in start_point:
		x = i[0] + _ref_RandomNumber.get_int(MIN_SHIFT, MAX_SHIFT)
		y = i[1] + _ref_RandomNumber.get_int(MIN_SHIFT, MAX_SHIFT)
		neighbor = Game_CoordCalculator.get_neighbor_xy(x, y, 1)
		for j in range(0, neighbor.size()):
			if (counter_index == 0) and (j == 0):
				continue
			x = neighbor[j].x
			y = neighbor[j].y
			_occupy_position(x, y)
			_add_building_to_blueprint(_spr_Wall, Game_SubTag.WALL, x, y)
		counter_index -= 1


func _get_top_left_position() -> Array:
	var valid_position := []
	var step := ROOM_SIZE + CORRIDOR_WIDTH

	# By setting MIN_X to 1, it is guarantted that every grid is reachable.
	for x in range(MIN_X, Game_DungeonSize.MAX_X, step):
		if x + ROOM_SIZE < Game_DungeonSize.MAX_X:
			for y in range(MIN_Y, Game_DungeonSize.MAX_Y, step):
				if y + ROOM_SIZE < Game_DungeonSize.MAX_Y:
					valid_position.push_back([x, y])
	return valid_position


func _create_pc() -> void:
	Game_WorldGenerator.create_by_coord(_all_coords, 1, _ref_RandomNumber, self,
			"_is_valid_pc_coord", [], "_create_pc_here", [])


func _is_valid_pc_coord(coord: Game_IntCoord, _retry: int, _arg: Array) -> bool:
	if _is_occupied(coord.x, coord.y):
		return false
	for i in Game_CoordCalculator.get_neighbor(coord, 1):
		if _is_occupied(i.x, i.y):
			return false
	return true


func _create_pc_here(coord: Game_IntCoord, _arg: Array) -> void:
	_add_actor_to_blueprint(_spr_PCHound, Game_SubTag.PC, coord.x, coord.y)
	for i in Game_CoordCalculator.get_neighbor(coord, Game_HoundData.PC_SIGHT,
			true):
		_occupy_position(i.x, i.y)
