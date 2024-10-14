extends DraggablePanelContainer

const SOUNDS_CLICK = [
	"pomodoro_click_1.wav", "pomodoro_click_2.wav", "pomodoro_click_3.wav"
]
const SOUNDS_5CLICK = ["pomodoro_5click.wav"]
const SOUNDS_CLICK_LIMIT = ["pomodoro_click_limit.wav"]

var timer_active := false
var timer : TimerResource

var starting_minutes := 5.0

func _ready():
	super._ready()
	timer = TimerResource.new()
	timer.negative_mode = true
	timer.finished.connect(_on_timer_finished)
	grabbed.connect(_on_grabbed)
	released.connect(_on_released)
	$ShakeDetectorComponent.shake_detected.connect(_on_shake_detected)
	%CheckButton.pressed.connect(_on_check_button_pressed)



func _unhandled_input(event: InputEvent) -> void:
	if mouse_in and not timer_active:
		if event is InputEventMouseButton and event.is_pressed():
			var step = 5
			if Input.is_key_pressed(KEY_SHIFT): step = 1
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				AudioManager.play_sfx_random(SOUNDS_CLICK_LIMIT if starting_minutes == 60 else SOUNDS_CLICK)
				starting_minutes = clamp(starting_minutes + step, 0, 60)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				AudioManager.play_sfx_random(SOUNDS_CLICK_LIMIT if starting_minutes == 0 else SOUNDS_CLICK)
				starting_minutes = clamp(starting_minutes - step, 0, 60)


func start(time_seconds:float) -> void:
	timer_active = true
	%CheckButton.button_pressed = true
	timer.reset()
	timer.set_time_from_seconds(time_seconds)

func stop() -> void:
	timer_active = false
	%CheckButton.button_pressed = false
	starting_minutes = ceil(timer.seconds / 300.0) * 5




func _physics_process(delta: float) -> void:
	if timer_active: 
		timer.update(delta)
		%TimerLabel.text = "[center]" + timer.timer_as_string(true)
	else:
		%TimerLabel.text = "[center]" + TimerResource.string_from_seconds(starting_minutes*60.0, true)


func _process(delta: float) -> void:
	super._process(delta)
	#if dragging:
		#rotation = lerp_angle(rotation, 0.0, delta*50)
	#else:
		#rotation_degrees += drag_delta_pos.x*0.5
	if abs(drag_delta_pos.x) <= 3.0:
		drag_delta_pos *= 0.95
	
	%ShadowSprite.global_position = %TomatoSprite.global_position + Vector2(0, 20 if dragging else 5)
	if dragging:
		%ShadowSprite.scale = lerp(%ShadowSprite.scale, Vector2.ONE*1.1, delta*10)
	else:
		%ShadowSprite.scale = lerp(%ShadowSprite.scale, Vector2.ONE*1.05, delta*3)
	#print_debug(drag_delta_pos.x)


func toggle_timer(value):
	if value == timer_active: return
	AudioManager.play_sfx("magic_ding.wav")
	if timer_active: 
		stop()
		%CheckButton.button_pressed = false
	else:
		if starting_minutes == 0: starting_minutes = 1
		start(starting_minutes*60) 
		%CheckButton.button_pressed = true

func _on_shake_detected():
	toggle_timer(!timer_active)

func _on_check_button_pressed():
	toggle_timer(%CheckButton.button_pressed)

func _on_timer_finished():
	timer_active = false
	starting_minutes = 0.0
	AudioManager.play_sfx("magic_ding.wav")
	$AlarmSound.play()
	%CheckButton.button_pressed = false

func _on_grabbed(_draggable):
	AudioManager.play_sfx("pomodoro_grabbed.wav")

func _on_released(_draggable):
	await get_tree().create_timer(0.1).timeout
	AudioManager.play_sfx("pomodoro_released.wav")
