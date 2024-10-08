extends Node2D

signal trash_used

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
	%ClosedSprite.visible = has_no_areas
	%OpenSprite.visible = not has_no_areas

func _on_area_exited_trash(_area:Area2D) -> void:
	pass
