class_name Game_FileParser


var output_text: String setget set_output_text, get_output_text
var output_json: Dictionary setget set_output_json, get_output_json
var output_line: Dictionary setget set_output_line, get_output_line
var parse_success: bool setget set_parse_success, get_parse_success


func get_output_text() -> String:
    return output_text


func set_output_text(file_content: String) -> void:
    output_text = file_content


func get_output_json() -> Dictionary:
    return output_json


func set_output_json(file_content: Dictionary) -> void:
    output_json = file_content


func get_output_line() -> Dictionary:
    return output_line


func set_output_line(file_content: Dictionary) -> void:
    output_line = file_content


func get_parse_success() -> bool:
    return parse_success


func set_parse_success(success: bool) -> void:
    parse_success = success
