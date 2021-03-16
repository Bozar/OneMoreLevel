extends Node2D
class_name Game_EndGame


# Emit this signal when PC's turn has already started, or when it is not PC's
# turn. Otherwies it may conflict with another signal: Schedule.turn_started.
signal game_over(win)


func player_lose() -> void:
	emit_signal("game_over", false)


func player_win() -> void:
	emit_signal("game_over", true)
