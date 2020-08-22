extends Node2D
class_name Game_HelpInput


var _ref_SwitchScreen: Game_SwitchScreen
var _ref_HelpVScroll: Game_HelpVScroll

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()


func _ready() -> void:
	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	# Leave help screen.
	if event.is_action_pressed(_new_InputTag.HELP):
		_ref_SwitchScreen.switch_to_screen(_new_ScreenTag.MAIN)
	# Scroll one line.
	elif event.is_action_pressed(_new_InputTag.MOVE_DOWN):
		_ref_HelpVScroll.slide_scroll_bar(true, true)
	elif event.is_action_pressed(_new_InputTag.MOVE_UP):
		_ref_HelpVScroll.slide_scroll_bar(true, false)
	# Scroll one page.
	elif event.is_action_pressed(_new_InputTag.PAGE_DOWN):
		_ref_HelpVScroll.slide_scroll_bar(false, true)
	elif event.is_action_pressed(_new_InputTag.PAGE_UP):
		_ref_HelpVScroll.slide_scroll_bar(false, false)
	# Scroll to top or bottom.
	elif event.is_action_pressed(_new_InputTag.SCROLL_TO_BOTTOM):
		_ref_HelpVScroll.scroll_to_top_or_bottom(true)
	elif event.is_action_pressed(_new_InputTag.SCROLL_TO_TOP):
		_ref_HelpVScroll.scroll_to_top_or_bottom(false)
	# Switch help text.
	elif event.is_action_pressed(_new_InputTag.SWITCH_HELP):
		_ref_HelpVScroll.switch_help_text()


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	set_process_unhandled_input(screen_tag == _new_ScreenTag.HELP)
