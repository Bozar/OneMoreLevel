const RAND_WARNING: String = "Rand is not of type Game_RandomNumber."


func rand_picker(source_array: Array, num_of_element: int, rand) -> void:
	var counter: int

	if rand is Game_RandomNumber:
		for i in range(num_of_element):
			counter = rand.get_int(i, source_array.size())
			swap_element(source_array, i, counter)
	else:
		push_warning(RAND_WARNING)
	source_array.resize(num_of_element)


# filter_in_func(source_array: Array, current_index: int,
#> optional_arg: Array) -> bool
# Return true if we need an array element.
func filter_element(source_array: Array, func_host: Object,
		filter_in_func: String, optional_arg: Array) -> void:
	var filter_in := funcref(func_host, filter_in_func)
	var counter: int = 0

	for i in range(source_array.size()):
		if filter_in.call_func(source_array, i, optional_arg):
			swap_element(source_array, counter, i)
			counter += 1
	source_array.resize(counter)


# get_counter_func(source_array: Array, current_index: int,
#> optional_arg: Array) -> int
# Return how many times an element should appear in the new array.
func duplicate_element(source_array: Array, func_host: Object,
		get_counter_func: String, optional_arg: Array) -> void:
	var get_counter := funcref(func_host, get_counter_func)
	var counter: int
	var tmp: Array = []

	for i in range(source_array.size()):
		counter = get_counter.call_func(source_array, i, optional_arg) - 1
		for _j in range(counter):
			tmp.push_back(source_array[i])
	merge(source_array, tmp)


func swap_element(source_array: Array,
		left_index: int, right_index: int) -> void:
	var tmp

	tmp = source_array[left_index]
	source_array[left_index] = source_array[right_index]
	source_array[right_index] = tmp


func merge(source_array: Array, merge_into_left: Array) -> void:
	var source_size: int = source_array.size()
	var merge_size: int = merge_into_left.size()

	source_array.resize(source_size + merge_size)
	for i in range(merge_size):
		source_array[i + source_size] = merge_into_left[i]


func reverse_key_value_in_dict(source_dict: Dictionary,
		reverse_dict: Dictionary) -> void:
	for i in source_dict.keys():
		reverse_dict[source_dict[i]] = i
