# npc_main.gd - прикрепи этот скрипт к CharacterBody2D (основной нод NPC)
extends CharacterBody2D

# === НАСТРОЙКИ ДВИЖЕНИЯ ===
@export var min_x: float = -15.0
@export var max_x: float = 70.0
@export var move_speed: float = 60.0
@export var min_move_time: float = 1.0
@export var max_move_time: float = 3.0
@export var min_idle_time: float = 0.5
@export var max_idle_time: float = 2.0

# === НАСТРОЙКИ AI ===
@export var ai_interval: float = 60.0  # Интервал между AI запросами (секунды)
@export var show_speech: bool = true   # Показывать ли текст над NPC

# === ССЫЛКИ НА НОДЫ ===
@onready var ai_assistant = $AI_Assistant      # Ссылка на AI нод
@onready var ai_timer = $AITimer               # Таймер для AI
@onready var speech_label = $SpeechBubble/Label if has_node("SpeechBubble/Label") else null

# === ПЕРЕМЕННЫЕ ===
var is_moving: bool = false
var move_timer: float = 0.0
var move_direction: int = 0
var ai_active: bool = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Список вопросов для AI
var ai_questions = [
	"Что видишь вокруг себя?",
	"Какой сегодня день?",
	"Что думаешь об этом месте?",
	"Есть совет для путешественника?",
	"Что самое интересное здесь?",
	"Как погода сегодня?",
	"Видел ли ты что-то необычное?",
	"Что важнее: сила или мудрость?"
]

func _ready():
	# === ИНИЦИАЛИЗАЦИЯ ДВИЖЕНИЯ ===
	start_new_action()
	
	# === ИНИЦИАЛИЗАЦИЯ AI ===
	# Подключаем сигналы от AI ассистента
	ai_assistant.response_received.connect(_on_ai_response)
	ai_assistant.request_failed.connect(_on_ai_error)
	
	# Настраиваем таймер AI
	ai_timer.wait_time = ai_interval
	ai_timer.timeout.connect(_on_ai_timer)
	ai_timer.start()
	
	# Скрываем speech bubble если есть
	if has_node("SpeechBubble"):
		$SpeechBubble.visible = false
	
	print("NPC запущен. AI запросы каждые ", ai_interval, " секунд")

func _physics_process(delta):
	# === ФИЗИКА И ДВИЖЕНИЕ ===
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Таймер движения
	move_timer -= delta
	if move_timer <= 0:
		start_new_action()
	
	# Применяем движение
	if is_moving:
		velocity.x = move_direction * move_speed
		$AnimatedSprite2D.flip_h = (move_direction < 0)
		if $AnimationPlayer:
			$AnimationPlayer.play("Run")
	else:
		velocity.x = 0
		if $AnimationPlayer:
			$AnimationPlayer.play("idle")
	
	move_and_slide()
	check_wall_collisions()

# === ФУНКЦИИ ДВИЖЕНИЯ ===
func start_new_action():
	is_moving = randf() > 0.4
	
	if is_moving:
		choose_safe_direction()
		move_timer = randf_range(min_move_time, max_move_time)
	else:
		move_timer = randf_range(min_idle_time, max_idle_time)

func choose_safe_direction():
	if position.x <= min_x + 5:
		move_direction = 1
	elif position.x >= max_x - 5:
		move_direction = -1
	else:
		move_direction = 1 if randf() > 0.5 else -1

func check_wall_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.7:
			move_direction *= -1
			$AnimatedSprite2D.flip_h = (move_direction < 0)
			move_timer = randf_range(0.1, 0.3)
			is_moving = true

# === AI ФУНКЦИИ ===
func _on_ai_timer():
	if not ai_active:
		return
	
	# Выбираем случайный вопрос
	var question = ai_questions[randi() % ai_questions.size()]
	print("\n[NPC AI] Задаю вопрос: ", question)
	
	# Показываем индикатор "думания"
	if show_speech and speech_label:
		speech_label.text = "...думаю..."
		if has_node("SpeechBubble"):
			$SpeechBubble.visible = true
	
	# Отправляем запрос к AI
	var success = ai_assistant.ask_ai(question)
	
	if not success:
		print("[NPC AI] Не удалось отправить запрос")

func _on_ai_response(response: String):
	print("[NPC AI] Получен ответ: ", response)
	
	# Показываем ответ над NPC
	if show_speech and speech_label:
		speech_label.text = response
		if has_node("SpeechBubble"):
			$SpeechBubble.visible = true
			
			# Прячем через 5 секунд
			await get_tree().create_timer(5.0).timeout
			$SpeechBubble.visible = false

func _on_ai_error(error_message: String):
	print("[NPC AI] Ошибка: ", error_message)
	
	if show_speech and speech_label:
		speech_label.text = "Не могу ответить..."
		if has_node("SpeechBubble"):
			$SpeechBubble.visible = true
			
			await get_tree().create_timer(3.0).timeout
			$SpeechBubble.visible = false

# === ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===
func toggle_ai(active: bool):
	ai_active = active
	if active:
		ai_timer.start()
		print("AI включен")
	else:
		ai_timer.stop()
		print("AI выключен")

func set_ai_interval(interval: float):
	ai_interval = interval
	ai_timer.wait_time = interval
	print("AI интервал изменён на ", interval, " секунд")
