extends VBoxContainer


const _new_SubGroupTag = preload("res://library/SubGroupTag.gd")

var _turn_counter: int = 0
var _turn_text: String = "Turn: {0}"

onready var _label_world: Label = get_node("World")
onready var _label_turn: Label = get_node("Turn")
onready var _label_help: Label = get_node("Help")
onready var _label_seed: Label = get_node("Seed")
onready var _label_message: Label = get_node("Message")


func _ready() -> void:
	_label_help.text = "Help: /"
	_label_help.modulate = "6c757d"

	_label_seed.text = "123-456-7890"
	_label_seed.modulate = "6c757d"

	_label_world.text = "Knight"
	_label_world.modulate = "6c757d"

	_update_turn()
	_label_turn.modulate = "adb5bd"

	# _label_message.text = "DANGER!"
	# _label_message.text = "You win.\n[ Space ]"
	_label_message.text = "You lose.\n[ Space ]"
	_label_message.modulate = "adb5bd"


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(_new_SubGroupTag.PC):
		_turn_counter += 1
		_update_turn()


func _update_turn() -> void:
	_label_turn.text = _turn_text.format([_turn_counter])
