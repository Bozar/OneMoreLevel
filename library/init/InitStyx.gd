extends "res://library/init/WorldTemplate.gd"


func _init(parent_node: Node2D).(parent_node) -> void:
	pass


func get_blueprint() -> Array:
	_init_pc()

	return _blueprint


func _init_floor() -> void:
	pass


func _init_pc() -> void:
	_add_to_blueprint(_spr_PC,
			_new_MainGroupTag.ACTOR, _new_SubGroupTag.PC,
			0, 0)
