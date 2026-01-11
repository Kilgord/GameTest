# DialogUI.gd
extends CanvasLayer

@onready var label = $Panel/Label

func show_text(text: String):
	label.text = text
	show()  # Показываем окно

func hide_dialog():
	hide()  # Скрываем окно
	queue_free()  # Удаляем
