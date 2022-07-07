extends Node2D
class_name Game_SwitchScreen


signal screen_switched(source, target)


func set_screen(source: int, target: int) -> void:
	emit_signal("screen_switched", source, target)
