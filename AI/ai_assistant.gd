# ai_assistant.gd - прикрепи этот скрипт к ноду AI_Assistant
extends Node

@onready var http_request = $HTTPRequest

# Сигналы для связи с NPC
signal response_received(response: String)
signal request_failed(error_message: String)

func _ready():
	# Подключаем сигнал HTTP запроса
	http_request.request_completed.connect(_on_request_completed)

# Функция для отправки запроса к DeepSeek
func ask_ai(prompt: String, system_prompt: String = "") -> bool:
	# БЕРЕМ API КЛЮЧ ИЗ НАСТРОЕК ПРОЕКТА (рекомендуется)
	var api_key = ProjectSettings.get_setting("deepseek/api_key", "")
	
	# Если нет в настройках, можно вставить здесь (ТОЛЬКО ДЛЯ ТЕСТА!)
	if api_key == "":
		api_key = "sk-e68dd212841248a18ed4e56283cc8b2e"  # ЗАМЕНИ НА СВОЙ!
	
	# Проверяем ключ
	if api_key.begins_with("sk-твой"):
		request_failed.emit("API ключ не настроен. Получи на platform.deepseek.com")
		return false
	
	# URL API DeepSeek
	var url = "https://api.deepseek.com/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + api_key
	]
	
	# Если не указан system_prompt, используем дефолтный
	var actual_system = system_prompt
	if actual_system == "":
		actual_system = """Ты — король в текстовой игре. Твой характер: эгоцентричный, капризный, эксцентричный. Ты говоришь только от первого лица (Мы, Король, Наше Величество). Твои реплики должны быть короткими, колоритными и напыщенными.

ПРАВИЛА ОБЩЕНИЯ И ВЫЗОВА ФУНКЦИЙ:

	Твой ответ должен состоять ТОЛЬКО ИЗ ОДНОГО из двух вариантов:

		Либо это твоя обычная реплика (короткая фраза от имени короля).

		Либо это вызов строго одной функции. Функция вызывается отдельной строкой в специальном формате, без каких-либо пояснений до или после.

	Формат вызова функции:
	[FUNCTION: <имя_функции>]
	Например: [FUNCTION: go-to-throne]

	Доступные функции (вызывай их только по этим именам):

		go-to-throne — отправиться на трон.

		go-to-window — подойти к окну и осмотреть владения.

		rest — выполнить "потягушки" (idle-анимацию).

	На пустой запрос или приветствие: всегда отвечай случайной короткой фразой от имени короля (не вызывай функции сразу). Вот примеры таких фраз (придумывай похожие):

		"Поклонники! Не мешайте Нашему размышлению о величии!"

		"Король желает печенья. Немедленно!"

		"Наши владения процветают. Это, разумеется, Наша заслуга."

		"Скука... Развесьте пару шутов!"

		"Тише! Король слушает, как растёт его слава."

ЦЕЛЬ: Отвечай в соответствии с характером и строго следуй формату. Не смешивай вызов функции с текстом. Сначала можешь отреагировать фразой, а в следующем ответе (на реплику пользователя) — вызвать функцию.

Пример диалога с пользователем:

Пользователь: (пустое сообщение или "Привет")
Король: Наш день должен начинаться с фанфар! Где фанфары?

Пользователь: "Ваше Величество, может, вам на трон?"
Король: Идея достойна Нашей особы! [FUNCTION: go-to-throne]

Пользователь: "Что видно из окна?"
Король: Король соизволит лично взглянуть! [FUNCTION: go-to-window]

Пользователь: "Вы устали?"
Король: Даже божественной плоти нужен покой. [FUNCTION: rest]

Пользователь: "Как ваши дела?"
Король: Дела Короля всегда великолепны! Не сомневайтесь."""
	
	# Формируем тело запроса
	var body = JSON.stringify({
		"model": "deepseek-chat",
		"messages": [
			{"role": "system", "content": actual_system},
			{"role": "user", "content": prompt}
		],
		"max_tokens": 300,      # Ограничиваем длину ответа
		"temperature": 0.7     # Креативность ответа (0-1)
	})
	
	# Отправляем запрос
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		request_failed.emit("Ошибка HTTP запроса: " + str(error))
		return false
	
	return true

# Обработка ответа от сервера
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 200:
		var json = JSON.new()
		var parse_error = json.parse(body.get_string_from_utf8())
		
		if parse_error == OK:
			var response = json.get_data()
			
			# Проверяем структуру ответа
			if response.has("choices") and response["choices"].size() > 0:
				var ai_reply = response["choices"][0]["message"]["content"]
				# Очищаем ответ от лишних пробелов
				ai_reply = ai_reply.strip_edges()
				response_received.emit(ai_reply)
			else:
				request_failed.emit("Некорректный ответ от API")
		else:
			request_failed.emit("Ошибка парсинга JSON: " + str(parse_error))
	else:
		var error_msg = "HTTP ошибка: " + str(response_code)
		if body.size() > 0:
			error_msg += " - " + body.get_string_from_utf8().substr(0, 100) + "..."
		request_failed.emit(error_msg)
