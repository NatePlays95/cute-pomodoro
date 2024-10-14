extends TextureButton


@export var miniwindow : Control
@export var duration := 0.3

var scale_tween : Tween


func _ready() -> void:
	pressed.connect(_on_pressed)
	button_pressed = false
	if miniwindow:
		miniwindow.scale.y = 0.0
		miniwindow.visible = false


func _process(delta) -> void:
	if button_pressed:
		modulate = Color(1,1,1,1)
	else:
		if is_hovered():
			modulate = Color.ALICE_BLUE
		else:
			modulate = Color.BEIGE
	
	if Input.is_key_pressed(KEY_K):
		button_pressed = false


func _on_pressed() -> void:
	if not miniwindow: return
	if scale_tween: scale_tween.kill()
	
	scale_tween = create_tween().set_trans(Tween.TRANS_QUAD)
	scale_tween.set_ease(Tween.EASE_OUT)
	
	var scale_target := 1.0 if button_pressed else 0.0
	if button_pressed:
		scale_tween.tween_property(miniwindow, "visible", true, 0.1)
	scale_tween.tween_property(miniwindow, "scale:y", scale_target, duration)
	if not button_pressed:
		scale_tween.tween_property(miniwindow, "visible", false, 0.01)
	
