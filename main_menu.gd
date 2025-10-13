extends Control
@onready var buttons = $buttons





func _on_button_pressed():
	buttons.play()
	await buttons.finished
	get_tree().change_scene_to_file("res://node_2d.tscn")


	
func _on_button_3_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().quit()
