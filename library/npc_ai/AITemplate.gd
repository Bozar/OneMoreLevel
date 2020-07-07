const ObjectData := preload("res://scene/main/ObjectData.gd")
const SwitchSprite := preload("res://scene/main/SwitchSprite.gd")

var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: ObjectData
var _ref_SwitchSprite: SwitchSprite

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStatusTag := preload("res://library/ObjectStatusTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()


# Override.
func take_action(_pc: Sprite, _actor: Sprite, _node_ref: Array) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return
