extends Node2D
class_name Game_HelpInput


var _ref_SwitchScreen: Game_SwitchScreen

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputTag.HELP):
		_ref_SwitchScreen.switch_to_screen(_new_ScreenTag.MAIN)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	set_process_unhandled_input(screen_tag == _new_ScreenTag.HELP)
