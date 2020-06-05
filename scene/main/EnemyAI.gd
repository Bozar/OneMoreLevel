extends Node2D


signal enemy_warned(message)

const Schedule := preload("res://scene/main/Schedule.gd")
const AITemplate := preload("res://library/npc_ai/AITemplate.gd")

var _ref_Schedule: Schedule

var _new_SubGroupName := preload("res://library/SubGroupName.gd").new()
var _new_WorldName := preload("res://library/WorldName.gd").new()

var _new_DemoAI := preload("res://library/npc_ai/DemoAI.gd")

var _pc: Sprite
var _ai: AITemplate

var _select_world: Dictionary = {
	_new_WorldName.DEMO: _new_DemoAI,
	_new_WorldName.KNIGHT: _new_DemoAI,
}


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupName.PC):
		return

	_ai.take_action(_pc, current_sprite)
	if _ai.print_text != "":
		emit_signal("enemy_warned", _ai.print_text)
	_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	_ai = _select_world[new_world].new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupName.PC):
		_pc = new_sprite

