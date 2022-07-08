class_name Game_ConvertCoord


const START_X := 50
const START_Y := 54
const STEP_X := 26
const STEP_Y := 34

const MOUSE_START_X := START_X - 10
const MOUSE_START_Y := START_Y - 10


static func sprite_to_coord(this_sprite: Sprite) -> Game_IntCoord:
	return vector_to_coord(this_sprite.position)


static func vector_to_coord(vector_coord: Vector2) -> Game_IntCoord:
	var x := int((vector_coord.x - START_X) / STEP_X)
	var y := int((vector_coord.y - START_Y) / STEP_Y)

	return Game_IntCoord.new(x, y)


static func mouse_to_coord(mouse_event: InputEvent) -> Game_IntCoord:
	var x := int((mouse_event.position.x - MOUSE_START_X) / STEP_X)
	var y := int((mouse_event.position.y - MOUSE_START_Y) / STEP_Y)

	return Game_IntCoord.new(x, y)


static func coord_to_vector(x: int, y: int, x_offset := 0, y_offset := 0) \
		-> Vector2:
	var x_vector: int = START_X + STEP_X * x + x_offset
	var y_vector: int = START_Y + STEP_Y * y + y_offset

	return Vector2(x_vector, y_vector)
