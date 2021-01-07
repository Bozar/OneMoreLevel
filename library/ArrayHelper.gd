func random_picker(source_array: Array, num_of_element: int,
		rand: Game_RandomNumber) -> void:
	var counter: int

	for i in range(num_of_element):
		counter = rand.get_int(i, source_array.size())
		swap_element(source_array, i, counter)
	source_array.resize(num_of_element)


func swap_element(source_array: Array,
		left_index: int, right_index: int) -> void:
	var tmp

	tmp = source_array[left_index]
	source_array[left_index] = source_array[right_index]
	source_array[right_index] = tmp


func merge(source_array: Array, merge_into_left: Array) -> void:
	for i in merge_into_left:
		source_array.push_back(i)
