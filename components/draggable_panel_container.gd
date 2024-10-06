class_name DraggablePanelContainer
extends PanelContainer

signal grabbed(draggable:DraggablePanelContainer)
signal released(draggable:DraggablePanelContainer)

@export var drag_lerp_speed : float = 10
@export var drag_size_mult : float = 1.3
#@export var drag_should_rotate : bool = true
@export var drag_rotation_degrees : float = 5
@export var friction_after_release := 0.1
@export var scale_up_on_spawn := true

var mouse_in := false
var dragging := false
var drag_offset := Vector2.ZERO
var drag_delta_pos := Vector2.ZERO


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size/2
	if scale_up_on_spawn:
		scale = Vector2.ZERO
		var spawn_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		spawn_tween.tween_property(self, "scale", Vector2.ONE, 0.5)


func get_center_global_position() -> Vector2:
	pivot_offset = size/2
	return global_position + pivot_offset


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if mouse_in:
				dragging = true
				drag_offset = (global_position - get_global_mouse_position())*drag_size_mult
				get_parent().move_child(self, -1)
				#z_index = +10
				grabbed.emit(self)
		else:
			if dragging:
				dragging = false
				#z_index = 0
				released.emit(self)


func _process(delta) -> void:
	if dragging:
		var old_position = global_position
		global_position = lerp(global_position, get_global_mouse_position() + drag_offset, delta*drag_lerp_speed)
		drag_delta_pos = global_position - old_position
	else:
		global_position += drag_delta_pos
		drag_delta_pos *= 1 - friction_after_release
	
	if dragging:
		scale = scale.move_toward(Vector2.ONE * drag_size_mult, delta*10)
		rotation_degrees = lerp(rotation_degrees, drag_rotation_degrees, delta*10)
	else:
		if mouse_in: scale = scale.move_toward(Vector2.ONE * 1.05, delta)
		else: scale = scale.move_toward(Vector2.ONE, delta*3)
		rotation_degrees = lerp(rotation_degrees, 0.0, delta*10)

func _on_mouse_entered() -> void:
	mouse_in = true

func _on_mouse_exited() -> void:
	mouse_in = false
