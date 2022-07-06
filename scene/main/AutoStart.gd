extends Node2D
class_name Game_AutoStart


const PATH_TO_INIT := "../InitWorld"

var _started := false


func _process(_delta) -> void:
	if _started:
		queue_free()
		return

	get_node(PATH_TO_INIT).init_world()
	_started = true
