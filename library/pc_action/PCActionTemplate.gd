# Scripts such as [DungeonType]PCAction.gd inherit this script.
# All functions except getters and setters can be overriden.
# The child should also implement _init() to pass arguments.


var message: String setget set_message, get_message
var end_turn: bool setget set_end_turn, get_end_turn


func get_message() -> String:
	return message


func set_message(_message: String) -> void:
	pass


func get_end_turn() -> bool:
	return end_turn


func set_end_turn(_end_turn: bool) -> void:
	pass


func is_ground(_direction: String) -> bool:
	return false


func is_npc(_direction: String) -> bool:
	return false


func is_building(_direction: String) -> bool:
	return false


func move() -> void:
	pass


func attack() -> void:
	pass


func interact() -> void:
	pass


func wait() -> void:
	end_turn = true


func reset_status() -> void:
	end_turn = false
