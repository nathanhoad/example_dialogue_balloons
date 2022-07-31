extends Node


const NameInputDialogView := preload("res://name_input_dialog/name_input_dialog.tscn")


var player_name: String = ""


func ask_for_name() -> void:
	var name_input_dialog := NameInputDialogView.instance()
	get_tree().root.add_child(name_input_dialog)
	name_input_dialog.popup_centered()
	yield(name_input_dialog, "confirmed")
	player_name = name_input_dialog.name_edit.text
	name_input_dialog.queue_free()
