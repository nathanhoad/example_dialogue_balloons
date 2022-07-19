extends CanvasLayer


signal actioned(next_id)


const DialogueLine := preload("res://addons/dialogue_manager/dialogue_line.gd")


const COLORS = {
	"Nathan": "ff5741",
	"Coco": "f5cfa2"
}


onready var audio_stream_player := $AudioStreamPlayer
onready var dialogue_label := $DialogueLabel
onready var responses_menu := $Background/Margin/Responses
onready var response_template := $Background/Margin/ResponseTemplate


var dialogue: DialogueLine


func _ready() -> void:
	if not dialogue:
		queue_free()
		return
	
	response_template.hide()
	
	# Center the dialogue
	dialogue.dialogue = "[center]%s" % dialogue.dialogue
	
	dialogue_label.hide()
	dialogue_label.dialogue = dialogue
	yield(dialogue_label.reset_height(), "completed")
	
	# Set the colour and attach the dialogue to the character
	dialogue_label.set("custom_colors/default_color", Color(COLORS[dialogue.character]))
	var target: Node2D = get_tree().current_scene.find_node(dialogue.character)
	dialogue_label.rect_global_position = target.global_position - dialogue_label.rect_size * Vector2(0.5, 1)
	
	dialogue_label.show()
	dialogue_label.type_out()
	
	# Play sound and wait for sound to finish
	var stream = load("res://point_n_click_balloon/voice/en/%s.ogg" % dialogue.translation_key)
	audio_stream_player.stream = stream
	audio_stream_player.play()
	
	Events.emit_signal("character_started_talking", dialogue.character)
	yield(audio_stream_player, "finished")
	Events.emit_signal("character_finished_talking", dialogue.character)
	dialogue_label.hide()
	
	if dialogue.responses.size() == 0:
		next(dialogue.next_id)
	else:
		for response in dialogue.responses:
			var item: RichTextLabel = response_template.duplicate(DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS)
			item.bbcode_text = response.prompt
			item.connect("mouse_entered", self, "_on_response_mouse_entered", [item])
			item.connect("focus_entered", self, "_on_response_focus_entered", [item])
			item.connect("focus_exited", self, "_on_response_focus_exited", [item])
			item.connect("gui_input", self, "_on_response_gui_input", [item])
			item.show()
			responses_menu.add_child(item)
		configure_focus()
		


func next(next_id: String) -> void:
	emit_signal("actioned", next_id)
	queue_free()


### Helpers


func configure_focus() -> void:
	responses_menu.show()
	
	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]
		
		item.focus_mode = Control.FOCUS_ALL
		
		item.focus_neighbour_left = item.get_path()
		item.focus_neighbour_right = item.get_path()
		
		if i == 0:
			item.focus_neighbour_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbour_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()
		
		if i == items.size() - 1:
			item.focus_neighbour_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbour_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()
	
	items[0].grab_focus()


func get_responses() -> Array:
	var items: Array = []
	for child in responses_menu.get_children():
		if "disallowed" in child.name.to_lower(): continue
		items.append(child)
		
	return items


### Signals


func _on_response_mouse_entered(item):
	item.grab_focus()


func _on_response_focus_entered(item):
	item.set("custom_colors/default_color", COLORS["Nathan"])


func _on_response_focus_exited(item):
	item.set("custom_colors/default_color", Color.white)


func _on_response_gui_input(event, item):
	if event is InputEventMouseButton and event.is_pressed():
		next(dialogue.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		next(dialogue.responses[item.get_index()].next_id)
