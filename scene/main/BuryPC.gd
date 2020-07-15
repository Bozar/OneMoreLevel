extends Node2D


signal pc_is_dead()


func bury() -> void:
	emit_signal("pc_is_dead")
