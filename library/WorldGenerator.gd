class_name Game_WorldGenerator


const MAX_RETRY := 999
const ERR_MSG := "Too many retries."
const WARN_MSG := "Rand is not of type Game_RandomNumber."


# is_valid_coord_func(coord: Game_IntCoord, retry: int,
#> is_valid_coord_opt_arg: Array) -> bool
# create_here_func(coord: Game_IntCoord, create_here_opt_arg: Array) -> void
# post_process_grid_func(grid_coords: Array, post_process_grid_opt_arg: Array)
#> -> void
static func create_by_coord(grid_coords: Array, count_remaining: int, rand,
		func_host: Object,
		is_valid_coord_func: String, is_valid_coord_opt_arg: Array,
		create_here_func: String, create_here_opt_arg: Array,
		post_process_grid_func := "", post_process_grid_opt_arg := [],
		retry := 0) -> void:
	var is_valid_coord := funcref(func_host, is_valid_coord_func)
	var create_here := funcref(func_host, create_here_func)
	var post_process_grid: FuncRef

	# print(retry)
	if not (rand is Game_RandomNumber):
		push_warning(WARN_MSG)

	Game_ArrayHelper.shuffle(grid_coords, rand)
	for i in grid_coords:
		if is_valid_coord.call_func(i, retry, is_valid_coord_opt_arg):
			create_here.call_func(i, create_here_opt_arg)
			count_remaining -= 1
			if count_remaining < 1:
				return
	if post_process_grid_func != "":
		post_process_grid = funcref(func_host, post_process_grid_func)
		post_process_grid.call_func(grid_coords, post_process_grid_opt_arg)

	retry += 1
	if retry > MAX_RETRY:
		print(ERR_MSG)
		return
	create_by_coord(grid_coords, count_remaining, rand, func_host,
			is_valid_coord_func, is_valid_coord_opt_arg,
			create_here_func, create_here_opt_arg,
			post_process_grid_func, post_process_grid_opt_arg,
			retry)
