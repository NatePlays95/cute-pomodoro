extends Node2D

var packed_task_card = preload("res://components/task_card/task_card.tscn")



func _ready():
	%TrashArea.area_entered.connect(_on_area_entered_trash)
	
	await get_tree().create_timer(0.5).timeout
	load_cards()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			save_cards()

func load_cards() -> void:
	var loaded_cards = SaveManager.get_data("task_cards")
	if loaded_cards == null: return
	await set_cards_from_data(loaded_cards)
	print_debug("cards loaded")


func save_cards() -> void:
	var cards_list = get_cards_as_data()
	SaveManager.set_data("task_cards", cards_list)
	SaveManager.save_data()
	print_debug("cards saved")
	#TODO: thread and add popup!


func get_cards_as_data() -> Array:
	var cards_list = []
	for child in get_tree().current_scene.get_children():
		if child is TaskCard:
			var card := child as TaskCard
			var card_data := {
				"x": card.global_position.x,
				"y": card.global_position.y,
				"text": card.get_text()
			}
			cards_list.append(card_data)
	return cards_list


func set_cards_from_data(cards_list : Array) -> void:
	if cards_list == null: return
	if cards_list == [] or cards_list.size() == 0: return
	
	for card_data : Dictionary in cards_list:
		var x : float = card_data.get_or_add("x", get_viewport_rect().size.x/2)
		var y : float = card_data.get_or_add("y", get_viewport_rect().size.y/2)
		var text : String = card_data.get_or_add("text", "")
		#var color
		
		var card_instance = packed_task_card.instantiate()
		card_instance.global_position = Vector2(x, y)
		card_instance.set_text(text)
		get_tree().current_scene.add_child(card_instance)
		card_instance.grabbed.connect(_on_object_grabbed)
		card_instance.released.connect(_on_object_released)
		await get_tree().create_timer(0.1).timeout
	return



func _on_object_grabbed(object:DraggablePanelContainer) -> void:
	pass

func _on_object_released(object:DraggablePanelContainer) -> void:
	#for area in %TrashArea.get_overlapping_areas():
		#if area.get_parent() == object:
			#var move_tween = create_tween()
			#move_tween.tween_property(object, "global_position", %TrashArea.global_position, 0.1)
			#object.delete()
	pass

func _on_area_entered_trash(area:Area2D) -> void:
	var object = area.get_parent()
	if object is TaskCard:
		object.delete()
		var move_tween = create_tween()
		move_tween.tween_property(
			object, "global_position", %TrashArea.global_position, 0.19)
		move_tween.tween_interval(0.5)
		move_tween.tween_callback(save_cards)


func _on_btn_add_task_pressed() -> void:
	var card = packed_task_card.instantiate()
	card.global_position = get_viewport_rect().size/2
	card.global_position += Vector2(randf_range(-1.0,1.0)*100,randf_range(-1.0,1.0)*100)
	get_tree().current_scene.add_child(card)
	card.grabbed.connect(_on_object_grabbed)
	card.released.connect(_on_object_released)
	pass # Replace with function body.
