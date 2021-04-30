extends Node2D
class_name Game_InputTemplate


func _ready() -> void:
	set_process_unhandled_input(false)


func _verify_input(event: InputEvent, input_tag: String) -> bool:
	return event.is_action_pressed(input_tag)
