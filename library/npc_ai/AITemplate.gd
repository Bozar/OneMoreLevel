const AIFuncParam := preload("res://library/npc_ai/AIFuncParam.gd")

var print_text: String setget set_print_text, get_print_text

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()


# Override.
func take_action(_pc: Sprite, _actor: Sprite, _node_ref: AIFuncParam) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return
