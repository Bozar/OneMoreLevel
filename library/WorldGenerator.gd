class_name Game_WorldGenerator


const HARD_RETRY_LIMIT := 999
const WARN_RETRY := "Too many retries."
const WARN_RAND := "Rand is not of type Game_RandomNumber."


# is_valid_coord_func(coord: Game_IntCoord, retry: int,
#> is_valid_coord_opt_arg: Array) -> bool
# create_here_func(coord: Game_IntCoord, create_here_opt_arg: Array) -> void
static func create_by_coord(all_coords: Array,
		count_remaining: int, rand, func_host: Object,
		is_valid_coord_func: String, is_valid_coord_opt_arg: Array,
		create_here_func: String, create_here_opt_arg: Array,
		max_retry := HARD_RETRY_LIMIT, retry := 0) -> void:
	var is_valid_coord := funcref(func_host, is_valid_coord_func)
	var create_here := funcref(func_host, create_here_func)

	# print(retry)
	if not (rand is Game_RandomNumber):
		push_warning(WARN_RAND)
	if max_retry > HARD_RETRY_LIMIT:
		max_retry = HARD_RETRY_LIMIT

	if retry > max_retry:
		if max_retry == HARD_RETRY_LIMIT:
			push_warning(WARN_RETRY)
		return
	elif count_remaining < 1:
		return

	Game_ArrayHelper.shuffle(all_coords, rand)
	for i in all_coords:
		if is_valid_coord.call_func(i, retry, is_valid_coord_opt_arg):
			create_here.call_func(i, create_here_opt_arg)
			count_remaining -= 1
			if count_remaining < 1:
				return

	create_by_coord(all_coords, count_remaining, rand, func_host,
			is_valid_coord_func, is_valid_coord_opt_arg,
			create_here_func, create_here_opt_arg,
			max_retry, retry + 1)


static func init_array(this_array: Array, init_size: int, init_value) -> void:
	this_array.resize(init_size)
	for i in range(0, init_size):
		this_array[i] = init_value
