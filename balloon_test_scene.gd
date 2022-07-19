extends Node2D


export var Balloon: PackedScene
export var title := "start"
export var dialogue_resource: Resource
export var width := 1920
export var height := 1080


func _ready():
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Vector2(width, height))
	OS.window_size = Vector2(1920, 1080)
	OS.window_position = (OS.get_screen_size() - OS.window_size) * 0.5
	OS.window_fullscreen = false
	
	DialogueManager.connect("dialogue_finished", self, "_on_dialogue_finished")
	
	yield(get_tree().create_timer(0.4), "timeout")
	
	show_dialogue(title)


func show_dialogue(key: String) -> void:
	var dialogue = yield(dialogue_resource.get_next_dialogue_line(key), "completed")
	if dialogue != null:
		var balloon = Balloon.instance()
		balloon.dialogue = dialogue
		get_tree().current_scene.add_child(balloon)
		show_dialogue(yield(balloon, "actioned"))


### Signals


func _on_dialogue_finished():
	yield(get_tree().create_timer(0.4), "timeout")
	get_tree().quit()
