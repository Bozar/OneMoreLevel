extends "res://library/InputTemplate.gd"
class_name Game_HelpInput


var _ref_SwitchScreen: Game_SwitchScreen
var _ref_HelpVScroll: Game_HelpVScroll

var _new_InputTag := preload("res://library/InputTag.gd").new()
var _new_ScreenTag: = preload("res://library/ScreenTag.gd").new()

var _input_to_funcref: Dictionary


func _on_InitWorld_world_selected(_new_world: String) -> void:
	if _input_to_funcref.size() > 0:
		return

	_input_to_funcref = {
		_new_InputTag.HELP:
			[_ref_SwitchScreen, "switch_to_screen", [_new_ScreenTag.MAIN]],
		_new_InputTag.MOVE_DOWN:
			[_ref_HelpVScroll, "slide_scroll_bar", [true, true]],
		_new_InputTag.MOVE_UP:
			[_ref_HelpVScroll, "slide_scroll_bar", [true, false]],
		_new_InputTag.PAGE_DOWN:
			[_ref_HelpVScroll, "slide_scroll_bar", [false, true]],
		_new_InputTag.PAGE_UP:
			[_ref_HelpVScroll, "slide_scroll_bar", [false, false]],
		_new_InputTag.SCROLL_TO_BOTTOM:
			[_ref_HelpVScroll, "scroll_to_top_or_bottom", [true]],
		_new_InputTag.SCROLL_TO_TOP:
			[_ref_HelpVScroll, "scroll_to_top_or_bottom", [false]],
		_new_InputTag.NEXT_HELP:
			[_ref_HelpVScroll, "switch_help_text", [true]],
		_new_InputTag.PREVIOUS_HELP:
			[_ref_HelpVScroll, "switch_help_text", [false]],
	}


func _unhandled_input(event: InputEvent) -> void:
	for i in _input_to_funcref.keys():
		if _verify_input(event, i):
			funcref(_input_to_funcref[i][0], _input_to_funcref[i][1]) \
					.call_funcv(_input_to_funcref[i][2])
			break


func _on_SwitchScreen_screen_switched(screen_tag: String) -> void:
	set_process_unhandled_input(screen_tag == _new_ScreenTag.HELP)
