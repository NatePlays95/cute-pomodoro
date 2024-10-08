extends Node2D

var packed_task_card = preload("res://components/task_card/task_card.tscn")
var saving_thread : Thread


func _ready():
	saving_thread = Thread.new()
	$Trash.trash_used.connect(save_cards)
	
	await get_tree().create_timer(0.5).timeout
	load_cards()

func _exit_tree() -> void:
	save_cards()
	await saving_thread.wait_to_finish()

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
	#if saving_thread.is_alive(): await saving_thread.wait_to_finish()
	var cards_list = get_cards_as_data()
	_actually_save_cards(cards_list)
	#saving_thread.start(_actually_save_cards.bind(cards_list))
	#TODO: thread and add popup!

func _actually_save_cards(cards_list) -> void:
	SaveManager.set_data("task_cards", cards_list)
	SaveManager.save_data()
	print_debug("cards saved")

func get_cards_as_data() -> Array:
	var cards_list = []
	for child in get_tree().current_scene.get_children():
		if child is TaskCard:
			var card := child as TaskCard
			var card_data := {
				"x": card.global_position.x,
				"y": card.global_position.y,
				"text": card.get_text(),
				"color": card.current_color
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
		var color : int = card_data.get_or_add("color", 0)
		#var color
		
		var card_instance = packed_task_card.instantiate()
		card_instance.global_position = Vector2(x, y)
		card_instance.set_text(text)
		card_instance.change_color(color)
		get_tree().current_scene.add_child(card_instance)
		card_instance.grabbed.connect(_on_object_grabbed)
		card_instance.released.connect(_on_object_released)
		await get_tree().create_timer(0.1).timeout
	return



func _on_object_grabbed(object:DraggablePanelContainer) -> void:
	pass

func _on_object_released(object:DraggablePanelContainer) -> void:
	pass




func _on_btn_add_task_pressed() -> void:
	var card = packed_task_card.instantiate()
	card.global_position = get_viewport_rect().size/2
	card.global_position += Vector2(randf_range(-1.0,1.0)*100,randf_range(-1.0,1.0)*100)
	get_tree().current_scene.add_child(card)
	card.grabbed.connect(_on_object_grabbed)
	card.released.connect(_on_object_released)
	pass # Replace with function body.
