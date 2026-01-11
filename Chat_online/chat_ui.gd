extends Control

@onready var chat_log = $Panel/VBoxContainer/ChatLog
@onready var message_input = $Panel/VBoxContainer/HBoxContainer/MessageInput
@onready var send_button = $Panel/VBoxContainer/HBoxContainer/SendButton
@onready var connection_panel = $ConnectionPanel
@onready var ip_input = $ConnectionPanel/VBoxContainer/IPInput
@onready var port_input = $ConnectionPanel/VBoxContainer/PortInput
@onready var name_input = $ConnectionPanel/VBoxContainer/NameInput
@onready var connect_button = $ConnectionPanel/VBoxContainer/ConnectButton
@onready var status_label = $ConnectionPanel/VBoxContainer/StatusLabel

var socket = StreamPeerTCP.new()
var connected = false
var player_name = ""
var buffer = PackedByteArray()

func _ready():
	# Подключаем сигналы
	send_button.pressed.connect(_send_message)
	message_input.text_submitted.connect(_on_message_submitted)
	connect_button.pressed.connect(_connect_to_server)
	
	# Начальные значения
	ip_input.text = "127.0.0.1"
	port_input.text = "12345"
	name_input.text = "Игрок_" + str(randi() % 1000)

func _on_message_submitted(text):
	_send_message()

func _process(delta):
	# ВАЖНО: вызываем poll() для обновления состояния
	socket.poll()
	
	var status = socket.get_status()
	
	if status == StreamPeerTCP.STATUS_CONNECTED:
		# Обновляем статус
		if not connected:
			connected = true
			status_label.text = "Подключено к серверу"
			connection_panel.hide()  # Скрываем панель подключения
			message_input.grab_focus()  # Фокус на поле ввода
			
			# Отправляем никнейм сразу после подключения
			await get_tree().create_timer(0.1).timeout  # Даем время на установку
			_send_nickname()
		
		# Проверяем входящие сообщения
		_poll_messages()
		
	elif status == StreamPeerTCP.STATUS_CONNECTING:
		status_label.text = "Подключаемся..."
		
		# Автоматически пробуем завершить подключение
		# Можно добавить счетчик попыток
		
	elif status == StreamPeerTCP.STATUS_NONE:
		if connected:
			connected = false
			status_label.text = "Соединение разорвано"
			connection_panel.show()
			
	elif status == StreamPeerTCP.STATUS_ERROR:
		connected = false
		status_label.text = "Ошибка соединения"
		connection_panel.show()

func _connect_to_server():
	var ip = ip_input.text
	var port = int(port_input.text)
	player_name = name_input.text
	
	status_label.text = "Подключение..."
	
	# Отключаемся если уже подключены
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		socket.disconnect_from_host()
		await get_tree().create_timer(0.1).timeout
	
	# Сбрасываем состояние
	connected = false
	buffer.clear()
	
	# Подключаемся к серверу
	var error = socket.connect_to_host(ip, port)
	
	if error == OK:
		status_label.text = "Пытаемся подключиться..."
	else:
		status_label.text = "Ошибка подключения: " + str(error)
		connected = false

func _poll_messages():
	# Получаем доступные байты
	var available = socket.get_available_bytes()
	
	if available > 0:
		# Читаем данные из сокета
		var data = socket.get_data(available)
		var error = data[0]
		var byte_array = data[1]
		
		if error == OK:
			# Добавляем в буфер
			buffer.append_array(byte_array)
			
			# Обрабатываем полные сообщения
			_process_buffer()
		else:
			print("Ошибка чтения данных: ", error)

func _process_buffer():
	# Ищем символ новой строки в буфере
	var newline_pos = -1
	for i in range(buffer.size()):
		if buffer[i] == 10:  # 10 = \n
			newline_pos = i
			break
	
	# Если нашли полное сообщение
	while newline_pos != -1:
		# Извлекаем сообщение до символа новой строки
		var message_bytes = buffer.slice(0, newline_pos)
		buffer = buffer.slice(newline_pos + 1)
		
		# Конвертируем в строку
		var message = message_bytes.get_string_from_utf8()
		if message:
			message = message.strip_edges()
			print("DEBUG: Получено сообщение: ", message)
			_add_to_chat(message)
		
		# Ищем следующее сообщение
		newline_pos = -1
		for i in range(buffer.size()):
			if buffer[i] == 10:
				newline_pos = i
				break

func _send_nickname():
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		print("DEBUG: Отправляю никнейм: ", player_name)
		var nickname_msg = "/name " + player_name + "\n"
		var bytes = nickname_msg.to_utf8_buffer()
		socket.put_data(bytes)
		status_label.text = "Никнейм отправлен: " + player_name
	else:
		print("Не подключено для отправки никнейма")

func _send_message():
	if socket.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		status_label.text = "Не подключено к серверу!"
		return
	
	var text = message_input.text.strip_edges()
	if text == "":
		return
	
	print("DEBUG: Отправляю сообщение: ", text)
	
	# Отправляем на сервер
	var message = text + "\n"
	var bytes = message.to_utf8_buffer()
	socket.put_data(bytes)
	print("DEBUG: Сообщение отправлено")
	
	# Показываем свое сообщение в чате
	_add_to_chat("[Вы]: " + text)
	
	# Очищаем поле ввода
	message_input.text = ""
	message_input.grab_focus()

func _add_to_chat(message: String):
	# Убираем лишние переносы
	message = message.strip_edges()
	
	if message:
		# Добавляем в лог
		chat_log.text += message + "\n"
		
		# Ограничиваем историю (последние 100 строк)
		var lines = chat_log.text.split("\n")
		if lines.size() > 100:
			chat_log.text = "\n".join(lines.slice(-100))
		
		# Автоматическая прокрутка
		await get_tree().process_frame  # Ждем обновления UI
		chat_log.scroll_vertical = chat_log.get_line_count()

func _exit_tree():
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		socket.disconnect_from_host()
