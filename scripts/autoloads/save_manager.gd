extends Node

const encryption_key := "Gu4r4hLind0!"
var data := {}

func _ready():
	setup_default_data()
	var _err = load_data()
	#set_data("records/total_score", 2300)
	
	apply_settings()
	
	save_data()

func _exit_tree() -> void:
	save_settings()

func load_data():
	load_from_json()
	#load_from_file(true)
	pass

func save_data():
	save_to_json()
	#save_to_file(true)
	pass



## Please inst_to_dict your values first.
func set_data(key:String, value) -> void:
	assert(not value is Object)
	_set_data(key, value)

func get_or_default(key:String, default):
	var return_value = _get_data(key)
	if return_value == null: return default
	return return_value

func get_data(key:String):
	return _get_data(key)



func _set_data(key:String, value, dict=data) -> void:
	var split_key = key.split("/", false, 1)
	if split_key.size() == 1:
		if not dict.has(key):
			dict[key] = value
		elif value is Dictionary and dict[key] is Dictionary:
			dict[key].merge(value, true)
			print("merged contents")
		else:
			dict[key] = value
		return
	else:
		if not dict.has(split_key[0]):
			dict[split_key[0]] = {}
		if not dict[split_key[0]] is Dictionary:
			dict[split_key[0]] = {}
		_set_data(split_key[1], value, dict[split_key[0]])
		return

func _get_data(key:String, dict=data):
	var split_key = key.split("/", false, 1)
	if not dict.has(split_key[0]): 
		return null
	elif split_key.size() == 1:
		return dict[split_key[0]]
	else:
		var result = _get_data(split_key[1], dict[split_key[0]])
		if result == null and dict == data:
			printerr("Couldn't find data at key: '%s'" % key)
		return result

func _load_values_to_data_dict(savegame_dict:Dictionary) -> void:
	data.merge(savegame_dict, true)
	#TODO find a way to merge recursively

func reset_settings() -> void:
	data = {}
	setup_default_data()
	save_data()




func load_from_json() -> Error:
	var file_contents : String = FileAccess.get_file_as_string("user://save_game.json")
	if file_contents == "":
		return FileAccess.get_open_error()
	var dict = JSON.parse_string(file_contents)
	print_debug(dict)
	if dict == null:
		return ERR_PARSE_ERROR
	_load_values_to_data_dict(dict)
	return OK

func save_to_json() -> Error:
	var json_string = JSON.stringify(data, "\t")
	var file_access = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file_access.store_string(json_string)
	return OK

func load_from_file(encrypted:bool=false) -> Error:
	var file_access : FileAccess
	if encrypted:
		file_access = FileAccess.open_encrypted_with_pass("user://save_game.dat", FileAccess.READ, encryption_key)
	else:
		file_access = FileAccess.open("user://save_game.dat", FileAccess.READ)
	
	if file_access == null:
		return FileAccess.get_open_error()
	var file_contents : String = file_access.get_as_text()
	if file_contents == "" or file_contents == null :
		return FileAccess.get_open_error()
	
	var dict = JSON.parse_string(file_contents)
	print_debug(dict)
	if dict == null:
		return ERR_PARSE_ERROR
	
	_load_values_to_data_dict(dict)
	return OK

func save_to_file(encrypted:bool=false) -> Error:
	var json_string = JSON.stringify(data, "\t")
	var file_access : FileAccess
	if encrypted:
		file_access = FileAccess.open_encrypted_with_pass("user://save_game.dat", FileAccess.WRITE, encryption_key)
	else:
		file_access = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if file_access == null:
		return FileAccess.get_open_error()
	
	file_access.store_string(json_string)
	return OK





## Custom Implementation

func setup_default_data() -> void:
	data["settings"] = {
		"window_size": {"x":1280, "y":720},
		"is_window_maximized": false,
		"zoom": 1.0,
		"custom_background": "",
	}
	data["collectables"] = {}
	data["unlockables"] = {}


func save_settings() -> void:
	var window_size = get_window().size
	set_data("settings/window_size", {"x":window_size.x, "y":window_size.y})
	var window_maximized = get_window().mode == Window.MODE_MAXIMIZED
	set_data("settings/is_window_maximized", window_maximized)
	save_data()

func apply_settings() -> void:
	var window_size = get_data("settings/window_size")
	get_window().size = Vector2(window_size["x"], window_size["y"])
	get_window().move_to_center()
	var window_maximized = get_data("settings/is_window_maximized")
	if window_maximized: get_window().mode = Window.MODE_MAXIMIZED
	apply_custom_background(get_data("settings/custom_background"))
	apply_zoom(get_or_default("settings/zoom", 1.0))

func apply_custom_background(image_path) -> void:
	var image : Image = null
	var texture : ImageTexture = null
	if image_path == null or image_path == "": 
		printerr("Loading background image from null or empty path \"\". Making background empty.")
	else:
		image = Image.load_from_file(image_path)
	
	if image == null: 
		printerr("Couldn't load background image from path: <%s>" % image_path)
	else:
		texture = ImageTexture.create_from_image(image)
		#loaded successfully, so save:
		set_data("settings/custom_background", image_path if image_path != null else "")
	
	var bg_texturerect : TextureRect = get_tree().get_first_node_in_group("CUSTOM_BACKGROUND")
	if bg_texturerect == null: return
	bg_texturerect.texture = texture

func apply_zoom(value) -> void:
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.zoom = Vector2.ONE * value
