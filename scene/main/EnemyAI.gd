extends Node2D


signal enemy_warned(message)

const AITemplate := preload("res://library/npc_ai/AITemplate.gd")
const Schedule := preload("res://scene/main/Schedule.gd")
const ObjectData := preload("res://scene/main/ObjectData.gd")
const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const SwitchSprite := preload("res://scene/main/SwitchSprite.gd")

var _ref_Schedule: Schedule
var _ref_ObjectData: ObjectData
var _ref_DungeonBoard: DungeonBoard
var _ref_SwitchSprite: SwitchSprite

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()

var _new_DemoAI := preload("res://library/npc_ai/DemoAI.gd")
var _new_KnightAI := preload("res://library/npc_ai/KnightAI.gd")

var _world_tag: String
var _ai: AITemplate

var _select_world: Dictionary = {
	_new_WorldTag.DEMO: _new_DemoAI,
	_new_WorldTag.KNIGHT: _new_KnightAI,
}


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_ai.take_action(current_sprite)
	if _ai.print_text != "":
		emit_signal("enemy_warned", _ai.print_text)
	_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	_world_tag = new_world


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if not new_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	# Order matters here. Refer: AITemplate.gd.
	_ai = _select_world[_world_tag].new([
		new_sprite,
		_ref_ObjectData,
		_ref_DungeonBoard,
		_ref_SwitchSprite
	])
