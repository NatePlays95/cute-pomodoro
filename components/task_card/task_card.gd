class_name TaskCard
extends DraggablePanelContainer

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

func _on_grabbed(_self) -> void:
	get_area().process_mode = Node.PROCESS_MODE_DISABLED
	AudioManager.play_sfx_random(SOUNDS_GRABBED)

func _on_released(_self) -> void:
	get_area().process_mode = Node.PROCESS_MODE_INHERIT
	await get_tree().create_timer(0.1).timeout
	AudioManager.play_sfx_random(SOUNDS_RELEASED)

func _on_shaken() -> void:
	set_text("")
