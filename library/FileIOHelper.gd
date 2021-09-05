class_name Game_FileIOHelper


static func read_as_text(path_to_file: String) -> Game_FileParser:
	var new_file: File = File.new()
	var file_parser := Game_FileParser.new()

	if new_file.open(path_to_file, File.READ) == OK:
		file_parser.parse_success = true
		file_parser.output_text = new_file.get_as_text()
	else:
		file_parser.parse_success = false
	new_file.close()
	return file_parser


static func read_as_line(path_to_file: String) -> Game_FileParser:
	var new_file: File = File.new()
	var file_parser := Game_FileParser.new()
	var row: int = 0

	if new_file.open(path_to_file, File.READ) == OK:
		file_parser.parse_success = true
		file_parser.output_line = {}
		while not new_file.eof_reached():
			file_parser.output_line[row] = new_file.get_line()
			row += 1
	else:
		file_parser.parse_success = false
	new_file.close()
	return file_parser


static func read_as_json(path_to_file: String) -> Game_FileParser:
	var file_parser: Game_FileParser = read_as_text(path_to_file)
	var json_parser: JSONParseResult

	if file_parser.parse_success:
		json_parser = JSON.parse(file_parser.output_text)
		if json_parser.error == OK:
			file_parser.output_json = json_parser.get_result()
		else:
			file_parser.parse_success = false
	return file_parser


# https://docs.godotengine.org/en/stable/classes/class_directory.html
static func get_file_list(path_to_dir: String) -> Array:
	var dir := Directory.new()
	var __
	var file_name: String
	var file_list: Array = []

	if dir.open(path_to_dir) == OK:
		__ = dir.list_dir_begin(true, true)
		file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				file_list.push_back(dir.get_current_dir() + "/" + file_name)
			file_name = dir.get_next()
	return file_list


static func has_file(path_to_file: String) -> bool:
	return File.new().file_exists(path_to_file)
