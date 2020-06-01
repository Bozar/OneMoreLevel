extends Node2D


signal enemy_warned(message)

const Schedule := preload("res://scene/main/Schedule.gd")
const AITemplate := preload("res://library/npc_ai/AITemplate.gd")

var _ref_Schedule: Schedule

var _new_DemoAI := preload("res://library/npc_ai/DemoAI.gd")

var _new_SubGroupName := preload("res://library/SubGroupName.gd").new()
var _new_WorldName := preload("res://library/WorldName.gd").new()

var _pc: Sprite
var _ai: AITemplate


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupName.PC):
		return

	_ai.take_action(_pc, current_sprite)
	if _ai.print_text != "":
		emit_signal("enemy_warned", _ai.print_text)
	_ref_Schedule.end_turn()


func _on_InitWorld_world_selected(new_world: String) -> void:
	if new_world == _new_WorldName.DEMO:
		_ai = _new_DemoAI.new()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupName.PC):
		_pc = new_sprite

