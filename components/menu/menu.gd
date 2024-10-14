extends PanelContainer

signal button_pressed(button_name:String)

@export var buttons : Array = []

var handling_press_call := false

func _ready() -> void:
	for button in $HBoxContainer.get_children():
		#var button = get_node(busetton_path)
		button.pressed.connect(_on_button_pressed.bind(button))

func _on_button_pressed(button) -> void:
	if handling_press_call: return
	handling_press_call = true
	for other_button in $HBoxContainer.get_children():
		#var other_button = get_node(button_path)
		if other_button == button: continue
		if other_button.button_pressed:
			other_button.button_pressed = false
			other_button.pressed.emit()
	button_pressed.emit(button.name)
	handling_press_call = false
