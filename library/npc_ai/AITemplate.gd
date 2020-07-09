const AIFuncParam := preload("res://library/npc_ai/AIFuncParam.gd")
const SwitchSprite := preload("res://library/SwitchSprite.gd")

var print_text: String setget set_print_text, get_print_text

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_SwitchSprite: SwitchSprite

var _pc: Sprite
var _self: Sprite
var _node: AIFuncParam
var _pc_pos: Array
var _self_pos: Array


# Override.
func take_action(__pc: Sprite, _actor: Sprite, _node_ref: AIFuncParam) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return


func _set_local_var(pc: Sprite, actor: Sprite, node_ref: AIFuncParam) -> void:
	_pc = pc
	_self = actor
	_node = node_ref
	_pc_pos = _new_ConvertCoord.vector_to_array(_pc.position)
	_self_pos = _new_ConvertCoord.vector_to_array(_self.position)

	_new_SwitchSprite = SwitchSprite.new(_node.ref_ObjectData)
