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
var nickname_sent = false

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
	if connected:
		# Сначала проверяем входящие сообщения
		_check_for_messages()
		
		# Если подключились, но еще не отправили никнейм
		if not nickname_sent:
			# Простая проверка - отправляем никнейм через секунду после подключения
			await get_tree().create_timer(0.5).timeout
			print("DEBUG: Автоотправка никнейма: ", player_name)
			socket.put_utf8_string(player_name + "\n")
			nickname_sent = true
			status_label.text = "Никнейм отправлен!"
	
	# Автопрокрутка чата
	if chat_log and chat_log.get_v_scroll_bar():
		if chat_log.get_v_scroll_bar().value < chat_log.get_v_scroll_bar().max_value - 50:
			chat_log.scroll_vertical = chat_log.get_line_count()

func _connect_to_server():
	var ip = ip_input.text
	var port = int(port_input.text)
	player_name = name_input.text
	nickname_sent = false
	
	status_label.text = "Подключение..."
	
	# Подключаемся к серверу
	var error = socket.connect_to_host(ip, port)
	
	if error == OK:
		status_label.text = "Подключено! Отправляю никнейм..."
		connected = true
	else:
		status_label.text = "Ошибка подключения"
		connected = false

func _check_for_messages():
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var available_bytes = socket.get_available_bytes()
		
		if available_bytes > 0:
			# Безопасное чтение данных
			var message_bytes = PackedByteArray()
			
			for i in range(available_bytes):
				var byte = socket.get_8()
				if byte < 0:  # Ошибка чтения
					print("DEBUG: Ошибка чтения байта")
					break
				message_bytes.append(byte)
			
			if message_bytes.size() > 0:
				var message = message_bytes.get_string_from_utf8()
				if message:
					message = message.strip_edges()
					print("DEBUG: Получено сообщение: ", message)
					_add_to_chat(message)

func _send_message():
	if not connected:
		print("Не подключено к серверу!")
		return
	
	var text = message_input.text.strip_edges()
	if text == "":
		return
	
	print("DEBUG: Отправляю сообщение: ", text)
	
	# Отправляем на сервер
	socket.put_utf8_string(text + "\n")
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

func _exit_tree():
	if connected:
		socket.disconnect_from_host()
