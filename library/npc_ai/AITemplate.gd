const ObjectData := preload("res://scene/main/ObjectData.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const SwitchSprite := preload("res://scene/main/SwitchSprite.gd")
const DangerZone := preload("res://scene/main/DangerZone.gd")
const BuryPC := preload("res://scene/main/BuryPC.gd")

var print_text: String setget set_print_text, get_print_text

var _ref_ObjectData: ObjectData
var _ref_DungeonBoard: DungeonBoard
var _ref_SwitchSprite: SwitchSprite
var _ref_DangerZone: DangerZone
var _ref_BuryPC: BuryPC

var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()
var _new_ObjectStateTag := preload("res://library/ObjectStateTag.gd").new()
var _new_SpriteTypeTag := preload("res://library/SpriteTypeTag.gd").new()
var _new_MainGroupTag := preload("res://library/MainGroupTag.gd").new()
var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()

var _pc: Sprite
var _self: Sprite
var _pc_pos: Array
var _self_pos: Array


func _init(object_reference: Array) -> void:
	# Order matters here. Refer: EnemyAI.gd.
	_pc = object_reference[0]
	_ref_ObjectData = object_reference[1]
	_ref_DungeonBoard = object_reference[2]
	_ref_SwitchSprite = object_reference[3]
	_ref_DangerZone = object_reference[4]
	_ref_BuryPC = object_reference[5]

# Override.
func take_action(_actor: Sprite) -> void:
	pass


# Override.
func remove_data(_actor: Sprite) -> void:
	pass


func get_print_text() -> String:
	return print_text


func set_print_text(_text: String) -> void:
	return


func _set_local_var(actor: Sprite) -> void:
	_self = actor
	_pc_pos = _new_ConvertCoord.vector_to_array(_pc.position)
	_self_pos = _new_ConvertCoord.vector_to_array(_self.position)
