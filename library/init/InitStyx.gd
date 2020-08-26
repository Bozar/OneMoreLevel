extends "res://library/init/WorldTemplate.gd"


var _spr_Lighthouse := preload("res://sprite/Lighthouse.tscn")
var _spr_Harbor := preload("res://sprite/Harbor.tscn")
var _spr_StyxRiver := preload("res://sprite/StyxRiver.tscn")

var _new_StyxData := preload("res://library/npc_data/StyxData.gd").new()


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_pc()
	_init_building()
	_init_river()

	return _blueprint


func _init_floor() -> void:
	pass


func _init_pc() -> void:
	var x: int = 1
	var y: int = _new_DungeonSize.MAX_Y - 2

	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC, x, y)


func _init_building() -> void:
	var lighthouse_x: int = _new_DungeonSize.CENTER_X
	var lighthouse_y: int = _new_DungeonSize.CENTER_Y
	var harbor_x: int = _new_DungeonSize.MAX_X - 2
	var harbor_y: int = 1

	_set_static_area(lighthouse_x, lighthouse_y, _new_StyxData.LIGHTHOUSE)
	_set_static_area(harbor_x, harbor_y, _new_StyxData.HARBOR)

	_add_to_blueprint(_spr_Lighthouse,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.LIGHTHOUSE,
			lighthouse_x, lighthouse_y)
	_add_to_blueprint(_spr_Harbor,
			_new_MainGroupTag.BUILDING, _new_SubGroupTag.HARBOR,
			harbor_x, harbor_y)


func _set_static_area(x: int, y: int, max_range: int) -> void:
	var neighbor: Array = _new_CoordCalculator.get_neighbor(
			x, y, max_range, true)

	for i in neighbor:
		_occupy_position(i[0], i[1])


func _init_river() -> void:
	for i in range(_new_DungeonSize.MAX_X):
		for j in range(_new_DungeonSize.MAX_Y):
			if _is_occupied(i, j):
				continue
			_add_to_blueprint(_spr_StyxRiver,
					_new_MainGroupTag.GROUND, _new_SubGroupTag.STYX_RIVER,
					i, j)
