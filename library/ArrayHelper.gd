func random_picker(source_array: Array, num_of_element: int,
		rand: Game_RandomNumber) -> void:
	var counter: int

	for i in range(num_of_element):
		counter = rand.get_int(i, source_array.size())
		swap_element(source_array, i, counter)
	source_array.resize(num_of_element)


# filter_in_func(source_array: Array, current_index: int,
#> optional_arg: Array) -> bool
# Returns true if we need an array element.
func filter_element(source_array: Array, func_host: Object,
		filter_in_func: String, optional_arg: Array) -> void:
	var filter_in := funcref(func_host, filter_in_func)
	var counter: int = 0

	for i in range(source_array.size()):
		if filter_in.call_func(source_array, i, optional_arg):
			swap_element(source_array, counter, i)
			counter += 1
	source_array.resize(counter)


func swap_element(source_array: Array,
		left_index: int, right_index: int) -> void:
	var tmp

	tmp = source_array[left_index]
	source_array[left_index] = source_array[right_index]
	source_array[right_index] = tmp


func merge(source_array: Array, merge_into_left: Array) -> void:
	for i in merge_into_left:
		source_array.push_back(i)
