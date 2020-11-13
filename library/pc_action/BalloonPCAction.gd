extends "res://library/pc_action/PCActionTemplate.gd"


var _teleport_x: Dictionary
var _teleport_y: Dictionary
var _state_to_input: Dictionary


func _init(parent_node: Node2D).(parent_node) -> void:
	_teleport_x = {
		-1: _new_DungeonSize.MAX_X - 1,
		_new_DungeonSize.MAX_X: 0,
	}

	_teleport_y = {
		-1: _new_DungeonSize.MAX_Y - 1,
		_new_DungeonSize.MAX_Y: 0,
	}

	_state_to_input = {
		_new_ObjectStateTag.UP: _new_InputTag.MOVE_UP,
		_new_ObjectStateTag.DOWN: _new_InputTag.MOVE_DOWN,
		_new_ObjectStateTag.LEFT: _new_InputTag.MOVE_LEFT,
		_new_ObjectStateTag.RIGHT: _new_InputTag.MOVE_RIGHT,
	}


func switch_sprite(_pc: Sprite) -> void:
	pass


func set_target_position(direction: String) -> void:
	.set_target_position(direction)

	var x: int = _target_position[0]
	var y: int = _target_position[1]

	if _teleport_x.has(x):
		x = _teleport_x[x]
	if _teleport_y.has(y):
		y = _teleport_y[y]
	_target_position = [x, y]
