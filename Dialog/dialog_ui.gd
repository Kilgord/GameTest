extends CanvasLayer

@onready var label = $Panel/Label
@onready var responses_menu = $Panel/ResponsesMenu

var current_resource: DialogueResource 
var current_line: DialogueLine

func start_dialog(resource: DialogueResource, title: String):
	current_resource = resource 
	current_line = await DialogueManager.get_next_dialogue_line(resource, title)
	update_ui()
	show()

func update_ui():
	if current_line == null:
		hide()
		return
	
	# ВСЕГДА выводим текст персонажа
	label.text = current_line.text
	
	# Очищаем старые кнопки
	for child in responses_menu.get_children():
		child.queue_free()
	
	# Если есть варианты выбора
	if current_line.responses.size() > 0:
		for response in current_line.responses:
			var button = Button.new()
			button.text = response.text
			# Важно: используем .call_deferred, чтобы клик не пробрасывался дальше
			button.pressed.connect(func(): _on_response_selected(response.next_id))
			responses_menu.add_child(button)
		responses_menu.show()
	else:
		responses_menu.hide()

func _on_response_selected(next_id: String):
	# Переходим по ID, который мы указали в файле диалога
	current_line = await DialogueManager.get_next_dialogue_line(current_resource, next_id)
	update_ui()

func _input(event):
	# Если нажали Enter и сейчас НЕТ кнопок на экране
	if event.is_action_pressed("ui_accept") and is_visible():
		if current_line.responses.size() > 0:
			return # Если кнопки есть, Enter не работает!
			
		current_line = await DialogueManager.get_next_dialogue_line(current_resource, current_line.next_id)
		update_ui()
