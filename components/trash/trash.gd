extends Node2D

signal trash_used

var mouse_in := false

var open := false :
	set(value):
		if value and not open:
			AudioManager.play_sfx("trash_open.wav")
		if open and not value:
			AudioManager.play_sfx("trash_close.wav")
		open = value

func _ready():
	%TrashArea.area_entered.connect(_on_area_entered_trash)
	%TrashArea.area_exited.connect(_on_area_exited_trash)

func _on_area_entered_trash(area:Area2D) -> void:
	var object = area.get_parent()
	if object is TaskCard:
		AudioManager.play_sfx("crumple.wav")
		object.delete()
		var move_tween = create_tween()
		move_tween.tween_property(
			object, "global_position", %TrashArea.global_position, 0.19)
		move_tween.tween_interval(0.5)
		move_tween.tween_callback(trash_used.emit)

func _process(delta: float) -> void:
	var has_no_areas = %TrashArea.get_overlapping_areas().is_empty()
	mouse_in = get_global_mouse_position().distance_to(global_position) < 100
	mouse_in = mouse_in && DisplayServer.window_is_focused()
	open = (not has_no_areas) || mouse_in
	%OpenSprite.visible = open
	%ClosedSprite.visible = not open

func _on_area_exited_trash(_area:Area2D) -> void:
	pass

func _on_mouse_entered() -> void:
	#print_debug("hey")
	pass
