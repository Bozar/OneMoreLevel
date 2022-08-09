extends Node2D
class_name Game_Schedule


const FIRST_SIGNALS := ["first_turn_starting", "first_turn_started",]
const START_SIGNALS := ["turn_starting", "turn_started",]
const END_SIGNALS := ["turn_ending", "turn_ended",]

# warning-ignore: UNUSED_SIGNAL
signal first_turn_starting()
# warning-ignore: UNUSED_SIGNAL
signal first_turn_started()
# warning-ignore: UNUSED_SIGNAL
signal turn_starting(current_sprite)
# warning-ignore: UNUSED_SIGNAL
signal turn_started(current_sprite)
# warning-ignore: UNUSED_SIGNAL
signal turn_ending(current_sprite)
# warning-ignore: UNUSED_SIGNAL
signal turn_ended(current_sprite)

var _actors: Array = [null]
var _pointer: int = 0
var _end_game: bool = false
var _end_current_turn: bool = true
var _start_first_turn: bool = true


func end_turn() -> void:
	# The boolean variable _end_game could be set during an actor's turn, or
	# when a turn ends.
	if _end_game:
		return

	# Suppose NPC X is the currently active actor, and Y is the next one in row.
	# 1. EnemyAI calls remove(X).
	# 2. In Schedule, _goto_next() is called and _end_current_turn is set to
	# false.
	# 3. EnemyAI calls X.end_turn().
	# 4. In Schedule, we should start Y's turn, rather than ends it.
	if _end_current_turn:
		# print("{0}: End turn.".format([_get_current().name]))
		for i in END_SIGNALS:
			emit_signal(i, _get_current())
			if _end_game:
				return
		_goto_next()
	else:
		_end_current_turn = true

	if _end_game:
		return
	for i in START_SIGNALS:
		emit_signal(i, _get_current())


func init_schedule() -> void:
	if _start_first_turn:
		for i in FIRST_SIGNALS:
			emit_signal(i)
		for i in START_SIGNALS:
			emit_signal(i, _get_current())
		_start_first_turn = false


func _on_CreateObject_sprite_created(new_sprite: Sprite, main_tag: String,
		sub_tag: String, _x: int, _y: int, _layer: int) -> void:
	if main_tag == Game_MainTag.ACTOR:
		if sub_tag == Game_SubTag.PC:
			_actors[0] = new_sprite
		else:
			_actors.append(new_sprite)


func _on_RemoveObject_sprite_removed(remove_sprite: Sprite, _main_tag: String,
		_x: int, _y: int, _sprite_layer: int) -> void:
	var current_sprite: Sprite

	if remove_sprite == _get_current():
		_end_current_turn = false
		_goto_next()
	current_sprite = _get_current()

	_actors.erase(remove_sprite)
	_pointer = _actors.find(current_sprite)


func _on_EndGame_game_over(_win: bool) -> void:
	_end_game = true


func _get_current() -> Sprite:
	return _actors[_pointer] as Sprite


func _goto_next() -> void:
	_pointer += 1
	if _pointer > _actors.size() - 1:
		_pointer = 0
