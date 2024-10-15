extends PanelContainer


func _ready() -> void:
	_update_custombg_btn_text()

func _on_btn_loadbg_pressed() -> void:
	#SaveManager.apply_custom_background("./background.png")
	var customBgFileDialog : FileDialog = %CustomBGFileDialog
	customBgFileDialog.visible = true
	if OS.has_feature("editor"):
		customBgFileDialog.current_dir = "res://"
	else:
		customBgFileDialog.current_dir = OS.get_executable_path().get_base_dir()
	pass # Replace with function body.

func _on_custom_bg_file_dialog_file_selected(path: String) -> void:
	SaveManager.apply_custom_background(path)
	_update_custombg_btn_text()

func _update_custombg_btn_text() -> void:
	var custom_bg_path : String = SaveManager.get_data("settings/custom_background")
	if custom_bg_path == null or custom_bg_path == "": 
		custom_bg_path = "Load"
	else:
		var custom_path_sliced = custom_bg_path.split("/")
		custom_bg_path = custom_path_sliced[custom_path_sliced.size() - 1]
	%BtnLoadCustomBG.text = custom_bg_path

func _on_btn_clearbg_pressed() -> void:
	SaveManager.set_data("settings/custom_background", "")
	SaveManager.apply_custom_background("")
	_update_custombg_btn_text()
	pass # Replace with function body.
