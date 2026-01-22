extends Area2D

# Ссылки на узлы
@onready var sprite_god = $"../AztekGod"
@onready var rave_music = $"../RaveMusic"
@onready var fx_rect = get_node_or_null("../PostProcessLayer/ColorRect")

# Переменные состояния
var activated = false
var shake_intensity = 0.0
var madness_level = 0.0 
var pixel_stretch_level = 0.0 
var camera_ref: Camera2D = null

func _ready():
	# Начальное состояние: всё тихо и скрыто
	sprite_god.visible = false
	rave_music.stop()
	
	# Подключаем сигнал касания, если он еще не подключен
	if not body_entered.is_connected(_on_totem_body_entered):
		body_entered.connect(_on_totem_body_entered)

func _process(_delta):
	if camera_ref and activated:
		# 1. Тряска камеры (offset)
		camera_ref.offset = Vector2(
			randf_range(-shake_intensity, shake_intensity), 
			randf_range(-shake_intensity, shake_intensity)
		)
		
		# 2. Вращение всей сцены (rotation)
		# Раскачиваем камеру по синусоиде, амплитуда зависит от madness_level
		camera_ref.rotation = sin(Time.get_ticks_msec() * 0.002) * (0.3 * madness_level)

	# 3. Передаем параметры в шейдер бога (растягивание и аберрация)
	if sprite_god.material:
		sprite_god.material.set_shader_parameter("pixel_stretch", pixel_stretch_level)

func _on_totem_body_entered(body: Node2D):
	if not activated:
		activated = true
		sprite_god.visible = true
		rave_music.play()
		
		# Пытаемся найти камеру у того, кто вошел (игрока)
		camera_ref = body.get_node_or_null("Camera2D")
		
		if camera_ref:
			zoom_camera_out(camera_ref)
			mirror_effect_burst() # Запускаем глюки отзеркаливания
		
		start_rave_effect()
		_glitch_flash() # Запускаем цикл случайных цветовых глюков

func zoom_camera_out(cam: Camera2D):
	# Плавный отлет камеры для эпичности
	var tween = create_tween()
	tween.tween_property(cam, "zoom", Vector2(0.4, 0.4), 10.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func start_rave_effect():
	# --- РАДУГА ---
	var rainbow_tween = create_tween().set_loops()
	rainbow_tween.tween_property(sprite_god.material, "shader_parameter/hue_variation", 1.0, 1.5).from(0.0)
	
	# --- БАС-ТРЯСКА ---
	var shake_tween = create_tween().set_loops()
	shake_tween.tween_property(self, "shake_intensity", 3.1, 0.5) 
	shake_tween.tween_property(self, "shake_intensity", 3.0, 0.4)
	
	# --- ЗУМ-ПАНЧ (пульсация камеры в такт) ---
	var punch_tween = create_tween().set_loops()
	punch_tween.tween_property(camera_ref, "zoom", Vector2(0.42, 0.42), 0.6)
	punch_tween.tween_property(camera_ref, "zoom", Vector2(0.4, 0.4), 0.9)
	
	# --- СТРОБОСКОП ---
	var strobe_tween = create_tween().set_loops()
	strobe_tween.tween_property(sprite_god, "modulate", Color(5, 5, 5, 1), 0.05) # Вспышка
	strobe_tween.tween_property(sprite_god, "modulate", Color(1, 1, 1, 1), 0.05) # Норма
	strobe_tween.tween_interval(0.15)
	
	# --- НАРАСТАНИЕ БЕЗУМИЯ ---
	var madness_tween = create_tween()
	madness_tween.parallel().tween_property(self, "madness_level", 2.0, 12.0)
	madness_tween.parallel().tween_property(self, "pixel_stretch_level", 0.8, 10.0)
	
	# --- ЭФФЕКТЫ ОКРУЖЕНИЯ (WorldEnvironment) ---
	var env_node = get_node_or_null("../WorldEnvironment")
	if env_node and env_node.environment:
		var env_tween = create_tween()
		env_tween.tween_property(env_node.environment, "glow_strength", 1.8, 20.0)
		env_tween.tween_property(env_node.environment, "glow_bloom", 0.3, 15.0)
		
	if fx_rect:
		var fx_tween = create_tween()
		fx_tween.tween_property(fx_rect.material, "shader_parameter/chaos_amount", 1.0, 10.0)
		fx_tween.parallel().tween_property(fx_rect.material, "shader_parameter/glitch_intensity", 1.0, 6.0)
		fx_tween.parallel().tween_property(fx_rect.material, "shader_parameter/scanline_intensity", 1.0, 4.0)

func mirror_effect_burst():
	if not camera_ref: return
	# Серия быстрых переворотов экрана
	var m_tween = create_tween().set_loops(4)
	m_tween.tween_property(camera_ref, "scale", Vector2(-1, 1), 0.05)
	m_tween.tween_property(camera_ref, "scale", Vector2(1, 1), 0.05)
	m_tween.tween_interval(0.4)

func _glitch_flash():
	if not activated: return
	# Случайные микро-глюки: подергивание спрайта и смена цвета
	sprite_god.flip_h = !sprite_god.flip_h
	
	# Ждем случайное время и повторяем
	await get_tree().create_timer(randf_range(0.2, 1.5)).timeout
	_glitch_flash()
