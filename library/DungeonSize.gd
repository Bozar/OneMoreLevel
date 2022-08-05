class_name Game_DungeonSize


const MAX_X := 21
const MAX_Y := 15

const CENTER_X := 10
const CENTER_Y := 7

const ARROW_MARGIN := 32


static func init_dungeon_grids(dungeon: Dictionary, init_value = null,
		init_once := true) -> void:
	var is_empty := dungeon.size() < 1

	if (not is_empty) and init_once:
		return

	for x in range(0, MAX_X):
		if is_empty:
			dungeon[x] = []
			dungeon[x].resize(MAX_Y)
		if init_value != null:
			for y in range(0, MAX_Y):
				dungeon[x][y] = init_value


# get_init_value_func(x: int, y: int, optional_arg: Array)
# Return an initial value for dungeon[x][y].
static func init_dungeon_grids_by_func(dungeon: Dictionary, func_host: Object,
		get_init_value_func: String, optional_arg := [], init_once := true) \
		-> void:
	var is_empty := dungeon.size() < 1
	var get_init_value := funcref(func_host, get_init_value_func)

	if (not is_empty) and init_once:
		return

	for x in range(0, MAX_X):
		if is_empty:
			dungeon[x] = []
			dungeon[x].resize(MAX_Y)
		for y in range(0, MAX_Y):
			dungeon[x][y] = get_init_value.call_func(x, y, optional_arg)


static func init_all_coords(save_coords: Array) -> void:
	var row := 0

	save_coords.resize(MAX_X * MAX_Y)
	for x in range(0, MAX_X):
		for y in range(0, MAX_Y):
			save_coords[x + y + row] = Game_IntCoord.new(x, y)
		# Every row has (MAX_Y - 1) elements.
		row += MAX_Y - 1
