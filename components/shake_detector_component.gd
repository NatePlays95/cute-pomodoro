class_name ShakeDetectorComponentV2
extends Node2D

signal shake_detected



@export var shake_threshold := 5
## 6 samples per second.
@export var max_samples := 12
## Will only record movement if not disabled.
@export var disabled := false

var stored_positions = []
var stored_timestamps = []




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

func _physics_process(delta: float) -> void:
	if Engine.get_process_frames() % 5 == 0: #sample every 5 physics frames.
		if not disabled:
			_update_shake(delta)
			if _detect_shakes():
				shake_detected.emit()
				clear_stored_positions()
		else:
			clear_stored_positions()


func _update_shake(delta: float) -> void:
	stored_positions.append(global_position)
	if stored_positions.size() > max_samples:
		stored_positions.pop_front()

func _detect_shakes() -> bool:
	if stored_positions.size() < 3: return 0
	var direction_changes:int = 0
	for i in range(1, stored_positions.size()-1):
		var current_direction : Vector2 = stored_positions[i] - stored_positions[i-1]
		var next_direction : Vector2 = stored_positions[i+1] - stored_positions[i]
		
		if current_direction.length_squared() < 0.1: continue
		if next_direction.length_squared() < 0.1: continue
		
		var dot = current_direction.normalized().dot(next_direction.normalized())
		if dot < 0.2: #around 160°
			#var time_diff = stored_timestamps[i+1] - stored_timestamps[i]
			direction_changes += 1
	#print_debug(direction_changes)
	return direction_changes >= shake_threshold

func clear_stored_positions():
	stored_positions = []
