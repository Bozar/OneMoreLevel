extends Game_InputTemplate
class_name Game_DebugInput


var _ref_SwitchScreen: Game_SwitchScreen


func _unhandled_input(event: InputEvent) -> void:
	if _verify_input(event, Game_InputTag.CLOSE_MENU):
		_ref_SwitchScreen.set_screen(Game_ScreenTag.DEBUG, Game_ScreenTag.MAIN)


func _on_SwitchScreen_screen_switched(_source: int, target: int) -> void:
	set_process_unhandled_input(target == Game_ScreenTag.DEBUG)
