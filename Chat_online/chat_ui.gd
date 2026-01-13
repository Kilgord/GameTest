extends Control

#@onready var chat_log = $Panel/VBoxContainer/ChatLog
@onready var message_input = $Panel/VBoxContainer/HBoxContainer/MessageInput
@onready var send_button = $Panel/VBoxContainer/HBoxContainer/SendButton
@onready var connection_panel = $ConnectionPanel
@onready var ip_input = $ConnectionPanel/VBoxContainer/IPInput
@onready var port_input = $ConnectionPanel/VBoxContainer/PortInput
@onready var name_input = $ConnectionPanel/VBoxContainer/NameInput
@onready var connect_button = $ConnectionPanel/VBoxContainer/ConnectButton
@onready var status_label = $ConnectionPanel/VBoxContainer/StatusLabel
@onready var chat_log = $Panel/VBoxContainer/RichTextLabel

var socket = StreamPeerTCP.new()
var connected = false
var player_name = ""
var buffer = PackedByteArray()
var chat_active = false 
var block_game_input = false

func _ready():
	# Подключаем сигналы
	send_button.pressed.connect(_send_message)
	message_input.text_submitted.connect(_on_message_submitted)
	connect_button.pressed.connect(_connect_to_server)
	add_to_group("chat_system")
	# Начальные значения
	ip_input.text = "93.123.246.107"
	port_input.text = "7777"
	name_input.text = "Игрок_" + str(randi() % 1000)
	$Panel.hide()
	
	# Включаем обработку unhandled input
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent):
	# Обрабатываем переключение чата
	if event.is_action_pressed("toggle_chat"):
		if chat_active:
			# Закрываем чат
			chat_active = false
			block_game_input = false
			message_input.release_focus()
			$Panel.hide()
		else:
			# Открываем чат
			chat_active = true
			block_game_input = true
			$Panel.show()
			message_input.grab_focus()
		
		get_viewport().set_input_as_handled()
		return
	
	# ESC закрывает чат
	if chat_active and event.is_action_pressed("ui_cancel"):
		chat_active = false
		block_game_input = false
		message_input.release_focus()
		$Panel.hide()
		get_viewport().set_input_as_handled()
		return

func _on_message_submitted(text):
	_send_message()

func _process(delta):
	socket.poll()
	
	var status = socket.get_status()
	
	if status == StreamPeerTCP.STATUS_CONNECTED:
		if not connected:
			connected = true
			status_label.text = "Подключено к серверу"
			connection_panel.hide()
			
			await get_tree().create_timer(0.1).timeout
			_send_nickname()
		
		_poll_messages()
		
	elif status == StreamPeerTCP.STATUS_CONNECTING:
		status_label.text = "Подключаемся..."
		
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
	
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		socket.disconnect_from_host()
		await get_tree().create_timer(0.1).timeout
	
	connected = false
	buffer.clear()
	
	var error = socket.connect_to_host(ip, port)
	
	if error == OK:
		status_label.text = "Пытаемся подключиться..."
	else:
		status_label.text = "Ошибка подключения: " + str(error)
		connected = false

func _poll_messages():
	var available = socket.get_available_bytes()
	
	if available > 0:
		var data = socket.get_data(available)
		var error = data[0]
		var byte_array = data[1]
		
		if error == OK:
			buffer.append_array(byte_array)
			_process_buffer()
		else:
			print("Ошибка чтения данных: ", error)

func _process_buffer():
	var newline_pos = -1
	for i in range(buffer.size()):
		if buffer[i] == 10:
			newline_pos = i
			break
	
	while newline_pos != -1:
		var message_bytes = buffer.slice(0, newline_pos)
		buffer = buffer.slice(newline_pos + 1)
		
		var message = message_bytes.get_string_from_utf8()
		if message:
			message = message.strip_edges()
			_add_to_chat(message)
		
		newline_pos = -1
		for i in range(buffer.size()):
			if buffer[i] == 10:
				newline_pos = i
				break

func _send_nickname():
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
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
	
	var message = text + "\n"
	var bytes = message.to_utf8_buffer()
	socket.put_data(bytes)
	
	message_input.text = ""
	message_input.grab_focus()

func _add_to_chat(message: String):
	message = message.strip_edges()
	
	if message:
		chat_log.text += "[color=FFBA00]" + message + "[/color]\n"
		
		var lines = chat_log.text.split("\n")
		if lines.size() > 100:
			chat_log.text = "\n".join(lines.slice(-100))
		
		await get_tree().process_frame
		var v_scroll = chat_log.get_v_scroll_bar()
		if v_scroll:
			v_scroll.value = v_scroll.max_value

func _exit_tree():
	if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		socket.disconnect_from_host()
