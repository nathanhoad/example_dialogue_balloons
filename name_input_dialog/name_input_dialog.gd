extends AcceptDialog


onready var name_edit := $NameEdit


func _ready() -> void:
	register_text_enter(name_edit)
	get_close_button().hide()


### Signals


func _on_NameInputDialog_visibility_changed():
	name_edit.call_deferred("grab_focus")


func _on_NameInputDialog_popup_hide():
	show()
