extends "res://library/pc_action/PCActionTemplate.gd"


var _teleport_x: Dictionary
var _teleport_y: Dictionary
var _state_to_coord: Dictionary


func _init(parent_node: Node2D).(parent_node) -> void:
	_teleport_x = {
		-1: _new_DungeonSize.MAX_X - 1,
		_new_DungeonSize.MAX_X: 0,
	}

	_teleport_y = {
		-1: _new_DungeonSize.MAX_Y - 1,
		_new_DungeonSize.MAX_Y: 0,
	}

	_state_to_coord = {
		_new_ObjectStateTag.UP: [0, -1],
		_new_ObjectStateTag.DOWN: [0, 1],
		_new_ObjectStateTag.LEFT: [-1, 0],
		_new_ObjectStateTag.RIGHT: [1, 0],
	}


func switch_sprite(_pc: Sprite) -> void:
	pass


func wait() -> void:
	_wind_blow()
	if _ref_DungeonBoard.has_sprite(_new_MainGroupTag.TRAP,
			_source_position[0], _source_position[1]):
		_reach_destination()

	end_turn = true


func interact_with_trap() -> void:
	_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
			_source_position, _target_position)
	_reach_destination()

	end_turn = true


func set_target_position(direction: String) -> void:
	_wind_blow()
	.set_target_position(direction)
	_target_position = _try_move_over_border(_target_position)


func _wind_blow() -> void:
	var pc: Sprite = _ref_DungeonBoard.get_sprite(_new_MainGroupTag.ACTOR,
			_source_position[0], _source_position[1])
	var wind_direction: Array = _state_to_coord[_ref_ObjectData.get_state(pc)]
	var new_position: Array = [
		_source_position[0] + wind_direction[0],
		_source_position[1] + wind_direction[1]
	]

	new_position = _try_move_over_border(new_position)
	if not _ref_DungeonBoard.has_sprite(_new_MainGroupTag.BUILDING,
			new_position[0], new_position[1]):
		_ref_DungeonBoard.move_sprite(_new_MainGroupTag.ACTOR,
				_source_position, new_position)
		_source_position = new_position


func _try_move_over_border(position: Array) -> Array:
	var x: int = position[0]
	var y: int = position[1]

	if _teleport_x.has(x):
		x = _teleport_x[x]
	if _teleport_y.has(y):
		y = _teleport_y[y]

	return [x, y]


func _reach_destination() -> void:
	print("Trap")
