extends Control

@onready var ip_input = $IPInput
@onready var status_label = $StatusLabel

func _ready():
	ip_input.text = NetworkManager.get_local_ip()
	print("Menu ready")
	NetworkManager.connection_success.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.scene_loaded.connect(_on_scene_loaded)

func _on_connected():
	status_label.text = "Подключено"
	print("Connected signal received")

func _on_connection_failed():
	status_label.text = "Ошибка подключения"
	print("Connection failed signal received")

func _on_scene_loaded():
	status_label.text = "Сцена загружена!"
	print("Scene loaded signal received")

func _on_host_button_pressed():
	status_label.text = "Создаём сервер..."
	if NetworkManager.start_hosting():
		status_label.text = "Сервер создан. Ждём подключений..."
		print("Server started, ждём клиентов")
	else:
		status_label.text = "Ошибка создания сервера"
		print("Failed to start server")

func _on_join_button_pressed():
	var ip = ip_input.text.strip_edges()
	if ip == "":
		status_label.text = "Введите IP"
		return
	status_label.text = "Подключаемся..."
	if NetworkManager.connect_to_host(ip):
		status_label.text = "Подключено, ждём загрузки сцены..."
	else:
		status_label.text = "Ошибка подключения"

func _on_back_button_pressed():
	if NetworkManager.peer:
		NetworkManager.peer.close()
	queue_free()
