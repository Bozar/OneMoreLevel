extends Node2D
class_name Game_SwitchScreen


signal screen_switched(screen_tag)


func switch_to_screen(screen_tag: int) -> void:
	emit_signal("screen_switched", screen_tag)
