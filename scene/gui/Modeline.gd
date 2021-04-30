extends Label


func _ready() -> void:
	text = "Press Space to start game."


func _on_Schedule_turn_ended(current_sprite: Sprite) -> void:
	if current_sprite.is_in_group(Game_SubGroupTag.PC):
		text = ""


func _on_EnemyAI_enemy_warned(message: String) -> void:
	text = message
