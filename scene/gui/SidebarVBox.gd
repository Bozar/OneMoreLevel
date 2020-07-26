extends VBoxContainer


const TURN: String = "Turn"
const MESSAGE: String = "Message"
const WORLD: String = "World"
const HELP: String = "Help"
const SEED: String = "Seed"

const RandomNumber := preload("res://scene/main/RandomNumber.gd")
const DangerZone := preload("res://scene/main/DangerZone.gd")

var _new_SubGroupTag := preload("res://library/SubGroupTag.gd").new()
var _new_Palette := preload("res://library/Palette.gd").new()
var _new_WorldTag := preload("res://library/WorldTag.gd").new()
var _new_ConvertCoord := preload("res://library/ConvertCoord.gd").new()

var _ref_RandomNumber: RandomNumber
var _ref_DangerZone: DangerZone

var _node_to_color: Dictionary = {
	TURN: _new_Palette.STANDARD,
	MESSAGE: _new_Palette.STANDARD,
	WORLD: _new_Palette.SHADOW,
	HELP: _new_Palette.SHADOW,
	SEED: _new_Palette.SHADOW,
}

var _turn: String = "Turn: {0}"
var _danger: String = "DANGER!"
var _win: String = "You win.\n[ Space ]"
var _lose: String = "You lose.\n[ Space ]"
var _help: String = "Help: /"
var _seed: String = "{0}-{1}-{2}"

var _pc: Sprite
var _turn_counter: int = 0


func _on_InitWorld_world_selected(new_world: String) -> void:
	_set_color()

	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = ""

	get_node(WORLD).text = _new_WorldTag.get_world_name(new_world)
	get_node(HELP).text = _help
	get_node(SEED).text = _get_seed()


func _on_InitWorld_sprite_created(new_sprite: Sprite) -> void:
	if new_sprite.is_in_group(_new_SubGroupTag.PC):
		_pc = new_sprite


func _on_Schedule_turn_started(current_sprite: Sprite) -> void:
	if not current_sprite.is_in_group(_new_SubGroupTag.PC):
		return

	_turn_counter += 1
	get_node(TURN).text = _get_turn()
	get_node(MESSAGE).text = _get_warning()


func _set_color() -> void:
	for i in _node_to_color.keys():
		get_node(i).modulate = _node_to_color[i]


func _get_turn() -> String:
	return _turn.format([_turn_counter])


func _get_warning() -> String:
	var _pc_pos: Array = _new_ConvertCoord.vector_to_array(_pc.position)

	if _ref_DangerZone.is_in_danger(_pc_pos[0], _pc_pos[1]):
		return _danger
	return  ""


func _get_seed() -> String:
	var _rng_seed: String = String(_ref_RandomNumber.rng_seed)
	var _head: String = _rng_seed.substr(0, 3)
	var _body: String = _rng_seed.substr(3, 3)
	var _tail: String = _rng_seed.substr(6)

	return _seed.format([_head, _body, _tail])
