class_name TaskCard
extends DraggablePanelContainer

@export var possible_colors : Array[Color] = [Color("#ffea76")]
var current_color := 0

const SOUNDS_GRABBED = [
	"card_grabbed_1.wav", "card_grabbed_2.wav", "card_grabbed_3.wav"
]
const SOUNDS_RELEASED = [
	"card_released.wav"
]


func _ready():
	super._ready()
	grabbed.connect(_on_grabbed)
	released.connect(_on_released)
	$ShakeDetectorComponent.shake_detected.connect(_on_shaken)
	AudioManager.install_ui(%TextEdit)
	_on_released(self)

func delete():
	var delete_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	delete_tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	#delete_tween.tween_interval(0.1)
	delete_tween.tween_callback(queue_free)

func set_text(text_in:String) -> void:
	%TextEdit.text = text_in

func get_text() -> String:
	return %TextEdit.text

func get_area() -> Area2D:
	return $Area2D

func change_color(color_index:int):
	current_color = wrapi(color_index, 0, possible_colors.size())
	%CardSprite.modulate = possible_colors[current_color]



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if not mouse_in:
			%TextEdit.release_focus()
		else: 
			var mouse_event := event as InputEventMouseButton
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				change_color(current_color + 1)
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				change_color(current_color - 1)


func _process(delta: float) -> void:
	super._process(delta)
	if dragging:
		%PinSprite.position.y = lerp(%PinSprite.position.y, -200.0, delta*5)
		%ShadowSprite.scale = lerp(%ShadowSprite.scale, Vector2(1.05,1.1), delta*10)
		#%ShadowSprite.scale.lerp(Vector2.ONE * 1.05, delta*10)
	else:
		%PinSprite.position.y = lerp(%PinSprite.position.y, 0.0, delta*30)
		%ShadowSprite.scale = lerp(%ShadowSprite.scale, Vector2.ONE*1.02, delta*3)
		#%ShadowSprite.scale.lerp(Vector2.ONE, delta*3)



func _on_grabbed(_self) -> void:
	get_area().process_mode = Node.PROCESS_MODE_DISABLED
	AudioManager.play_sfx_random(SOUNDS_GRABBED)

func _on_released(_self) -> void:
	get_area().process_mode = Node.PROCESS_MODE_INHERIT
	%TextEdit.release_focus()
	await get_tree().create_timer(0.1).timeout
	AudioManager.play_sfx_random(SOUNDS_RELEASED)

func _on_shaken() -> void:
	#set_text("")
	pass
