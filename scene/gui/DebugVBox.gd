extends VBoxContainer
class_name Game_DebugVBox


const TRANSFER_NODE := "/root/TransferData"

const HEADER := "Header"
const SETTING := "SettingVBox"
const FOOTER := "Footer"
const SEED_LABEL := "SettingVBox/Seed/GUIText"
const SEED_INPUT := "SettingVBox/Seed/GUIInput"
const INCLUDE_LABEL := "SettingVBox/IncludeWorld/GUIText"
const INCLUDE_INPUT := "SettingVBox/IncludeWorld/GUIInput"
const WIZARD_LABEL := "SettingVBox/WizardMode/GUIText"
const WIZARD_INPUT := "SettingVBox/WizardMode/GUIInput"
const EXCLUDE_LABEL := "SettingVBox/ExcludeWorld/GUIText"
const EXCLUDE_INPUT := "SettingVBox/ExcludeWorld/GUIInput"
const SHOW_LABEL := "SettingVBox/ShowFullMap/GUIText"
const SHOW_INPUT := "SettingVBox/ShowFullMap/GUIInput"

const HEADER_TEXT := "# Debug Menu\n\n[Esc: Exit debug]"
const SEED_TEXT := "Seed"
const SEED_PLACEHOLDER := "DEFAULT VALUE: 0"
const INCLUDE_TEXT := "Include"
const INCLUDE_PLACEHOLDER := "EXAMPLE: BARON, FACTORY, RAILGUN"
const WIZARD_TEXT := "Wizard"
const WIZARD_PLACEHOLDER := "DEFAULT VALUE: FALSE"
const EXCLUDE_TEXT := "Exclude"
const EXCLUDE_PLACEHOLDER := "INITIAL VALUE: DEMO"
const SHOW_TEXT := "ShowMap"
const SHOW_PLACEHOLDER := "DEFAULT VALUE: FALSE"

const TRUE_PATTERN := ["true", "1"]
const VERSION_PREFIX := "Version: "
const SEPARATOR := ","
const TRAILING_SPACE := " "

var _ref_Palette: Game_Palette


func _ready() -> void:
	visible = false


func _on_InitWorld_world_selected(_new_world: String) -> void:
	_init_text_color()
	_init_label_text()
	_init_input_placeholder()


func _on_SwitchScreen_screen_switched(source: int, target: int) -> void:
	if target == Game_ScreenTag.DEBUG:
		visible = true
		get_node(SEED_INPUT).grab_focus()
		_load_settings()
	elif source == Game_ScreenTag.DEBUG:
		visible = false
		_save_settings()


func _init_label_text() -> void:
	var label_to_text := {
		HEADER: HEADER_TEXT,
		FOOTER: Game_SidebarText.VERSION.format([VERSION_PREFIX]),
		SEED_LABEL: SEED_TEXT,
		INCLUDE_LABEL: INCLUDE_TEXT,
		WIZARD_LABEL: WIZARD_TEXT,
		EXCLUDE_LABEL: EXCLUDE_TEXT,
		SHOW_LABEL: SHOW_TEXT,
	}

	for i in label_to_text.keys():
		get_node(i).text = label_to_text[i]


func _init_input_placeholder() -> void:
	var input_to_placeholder := {
		SEED_INPUT: SEED_PLACEHOLDER,
		INCLUDE_INPUT: INCLUDE_PLACEHOLDER,
		WIZARD_INPUT: WIZARD_PLACEHOLDER,
		EXCLUDE_INPUT: EXCLUDE_PLACEHOLDER,
		SHOW_INPUT: SHOW_PLACEHOLDER,
	}

	for i in input_to_placeholder.keys():
		get_node(i).placeholder_text = input_to_placeholder[i]


func _init_text_color() -> void:
	var node_to_color := {
		HEADER: true,
		SETTING: true,
		FOOTER: false,
	}

	for i in node_to_color:
		get_node(i).modulate = _ref_Palette.get_text_color(node_to_color[i])


func _load_settings() -> void:
	var transfer: Game_TransferData = get_node(TRANSFER_NODE)

	_load_as_string(transfer.rng_seed, SEED_INPUT)
	_load_as_string(transfer.wizard_mode, WIZARD_INPUT)
	_load_as_string(transfer.show_full_map, SHOW_INPUT)

	_load_from_array(transfer.include_world, INCLUDE_INPUT)
	_load_from_array(transfer.exclude_world, EXCLUDE_INPUT)


func _save_settings() -> void:
	var transfer: Game_TransferData = get_node(TRANSFER_NODE)

	transfer.rng_seed = _save_as_float(SEED_INPUT)

	transfer.include_world = _save_as_array(INCLUDE_INPUT)
	transfer.exclude_world = _save_as_array(EXCLUDE_INPUT)

	transfer.wizard_mode = _save_as_bool(WIZARD_INPUT)
	transfer.show_full_map = _save_as_bool(SHOW_INPUT)


func _load_from_array(source: Array, target: String) -> void:
	var tmp := ""

	for i in range(0, source.size()):
		if i < source.size() - 1:
			tmp += source[i] + SEPARATOR + TRAILING_SPACE
		else:
			tmp += source[i]
	get_node(target).text = tmp


func _load_as_string(source, target: String) -> void:
	get_node(target).text = String(source).to_lower()


func _save_as_array(source: String) -> Array:
	var tmp = get_node(source).text.to_lower()

	tmp = tmp.split(SEPARATOR)
	for i in range(0, tmp.size()):
		tmp[i] = tmp[i].strip_edges()
	return tmp


func _save_as_bool(source: String) -> bool:
	var tmp: String = get_node(source).text.to_lower().strip_edges()

	if tmp in TRUE_PATTERN:
		return true
	return false


func _save_as_float(source: String) -> float:
	return float(get_node(source).text)
