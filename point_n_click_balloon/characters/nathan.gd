extends AnimatedSprite


func _ready() -> void:
	Events.connect("character_started_talking", self, "_on_character_started_talking")
	Events.connect("character_finished_talking", self, "_on_character_finished_talking")


### Signals


func _on_character_started_talking(character_name: String) -> void:
	if character_name == "Nathan":
		play("Talking")


func _on_character_finished_talking(character_name: String) -> void:
	if character_name == "Nathan":
		play("Default")
