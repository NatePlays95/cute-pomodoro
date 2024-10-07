class_name ShakeDetectorComponent
extends Node2D

signal shake_detected

@export var detect_threshold := 2.0
@export var forget_threshold := 0.8
@export var decay_rate := 0.97

@export var debug_label_visible := false

var shake_successful := false :
	set(value):
		if value == true and shake_successful == false:
			shake_detected.emit()
			#print_debug("shake! ", randf())
		shake_successful = value

var sum := 0.0
var old_global_position := Vector2.ZERO
var old_delta_pos := Vector2.ZERO

var startup_timer := 0.5
var debug_label : Label = null

func _ready():
	visible = false
	old_global_position = global_position
	sum = -100
	
	debug_label = Label.new()
	if debug_label_visible: add_child(debug_label)

func _physics_process(delta: float) -> void:
	if startup_timer > 0: 
		startup_timer -= delta
		return # dont trigger the shake on entry
	
	var delta_pos = global_position - old_global_position
	var dot = delta_pos.normalized().dot(old_delta_pos.normalized())
	
	if dot < -0.01:
		sum += abs(dot)
	sum *= decay_rate
	
	debug_label.text = "%.2f" % sum 
	
	if sum >= detect_threshold:
		shake_successful = true
	elif sum < forget_threshold:
		shake_successful = false
	
	old_delta_pos = global_position - old_global_position
	old_global_position = global_position 
	if old_delta_pos.length_squared() < 0.1:
		reset()

func reset():
	sum = 0
