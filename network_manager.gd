extends Node

signal connection_success
signal connection_failed
signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal scene_loaded
const PLAYER_SCENE := preload("res://character_body_2d.tscn")
const SCENE_PATH := "res://node_2d.tscn"
const PORT = 7777
const MAX_PLAYERS = 4

var peer: ENetMultiplayerPeer
var scene_loaded_on_server = false
var last_scene = null

func _ready():
	if multiplayer.is_server():
		print("Сервер запущен")
	else:
		print("Клиент запущен")


func _process(delta):
	var current = get_tree().current_scene
	if current != last_scene:
		last_scene = current
		_on_scene_changed()

func _on_scene_changed():
	print("Сцена изменилась на: ", last_scene)
	emit_signal("scene_loaded")

func start_hosting() -> bool:
	if peer:
		peer.close()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		printerr("Failed to create server:", err)
		emit_signal("connection_failed")
		return false
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(Callable(self, "_on_peer_connected"))
	peer.peer_disconnected.connect(Callable(self, "_on_peer_disconnected"))
	print("✅ Server created on port ", PORT)
	emit_signal("connection_success")
	return true

func connect_to_host(ip: String) -> bool:
	if peer:
		peer.close()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, PORT)
	if err != OK:
		printerr("Failed to connect to server:", err)
		emit_signal("connection_failed")
		return false
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(Callable(self, "_on_peer_connected"))
	peer.peer_disconnected.connect(Callable(self, "_on_peer_disconnected"))
	print("✅ Connected to host ", ip)
	emit_signal("connection_success")
	return true

func _on_peer_connected(id: int) -> void:
	print("Player connected: ", id)
	emit_signal("player_connected", id)
	if multiplayer.is_server():
		# Отправляем новому клиенту загрузить сцену
		rpc_id(id, "load_game_scene")
		# Спавним игрока на сервере
		spawn_player(id)
		# Сервер загружает сцену один раз
		if not scene_loaded_on_server:
			scene_loaded_on_server = true
			print("Server (host) загружает игровую сцену")
			load_game_scene()

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected: ", id)
	emit_signal("player_disconnected", id)
	var player_node = get_tree().current_scene.get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()

@rpc("any_peer")
func load_game_scene():
	var err = get_tree().change_scene_to_file(SCENE_PATH)
	if err == OK:
		await get_tree().process_frame
		emit_signal("scene_loaded")
	else:
		printerr("❌ Failed to load scene: ", err)


func spawn_player(id: int) -> void:
	if not multiplayer.is_server():
		return

	await get_tree().process_frame  # ждём, пока сцена загрузится

	var current_scene = get_tree().current_scene
	if current_scene == null:
		print("Сцена ещё не загружена")
		return
	
	if current_scene.has_node(str(id)):
		print("Игрок с таким ID уже существует")
		return

	# Далее спавним игрока
	var player_scene = preload("res://character_body_2d.tscn")
	var player = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	player.position = get_spawn_position_for_id(id)
	current_scene.add_child(player)

	rpc_id(id, "client_spawn_player", player.position, id)



@rpc("any_peer", "call_local")
func client_spawn_player(pos: Vector2, authority_id: int) -> void:
	while get_tree().current_scene == null:
		await get_tree().process_frame

	if get_tree().current_scene.has_node(str(authority_id)):
		print("Клиент: игрок уже существует, пропускаем спавн")
		return

	var player = PLAYER_SCENE.instantiate()
	player.name = str(authority_id)
	player.set_multiplayer_authority(authority_id)
	player.position = pos
	get_tree().current_scene.add_child(player)

	print("Клиент создал игрока с ID %s, Authority? %s" % [authority_id, player.is_multiplayer_authority()])


func get_spawn_position_for_id(id: int) -> Vector2:
	# Верни позицию спавна для игрока по ID
	# Здесь просто пример — ставим игроков на разные позиции по ID
	return Vector2(150 + 50 * (id % 5), 100)


func get_local_ip() -> String:
	var interfaces = IP.get_local_interfaces()
	for iface in interfaces:
		for addr in iface["addresses"]:
			if addr.find(".") != -1 and not addr.begins_with("127."):
				return "127.0.0.1"
	return "127.0.0.1"
