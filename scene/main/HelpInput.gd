extends Node2D
class_name Game_HelpInput


var _ref_SwitchScreen: Game_SwitchScreen
var _ref_HelpVScroll: Game_HelpVScroll

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(_new_InputTag.HELP):
		_ref_SwitchScreen.switch_to_screen(_new_ScreenTag.MAIN)
	elif event.is_action_pressed(_new_InputTag.MOVE_DOWN):
		_ref_HelpVScroll.slide_scroll_bar(true, true)
	elif event.is_action_pressed(_new_InputTag.MOVE_UP):
		_ref_HelpVScroll.slide_scroll_bar(true, false)
	elif event.is_action_pressed(_new_InputTag.PAGE_DOWN):
		_ref_HelpVScroll.slide_scroll_bar(false, true)
	elif event.is_action_pressed(_new_InputTag.PAGE_UP):
		_ref_HelpVScroll.slide_scroll_bar(false, false)


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	set_process_unhandled_input(screen_tag == _new_ScreenTag.HELP)
	_ref_HelpVScroll.reset_scroll_bar()
