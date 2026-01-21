extends Area2D

@onready var sprite_god = $"../AztekGod"
@onready var rave_music = $"../RaveMusic"

var activated = false

func _ready():
	# На всякий случай принудительно гасим всё при старте
	sprite_god.visible = false
	rave_music.stop()
	# Сигнал лучше подключать здесь кодом, если не уверен в интерфейсе
	if not body_entered.is_connected(_on_totem_body_entered):
		body_entered.connect(_on_totem_body_entered)

func _on_totem_body_entered(body: Node2D):
	if not activated:
		activated = true
		sprite_god.visible = true
		rave_music.play()
		start_rave_effect()
		
		# Ищем камеру у того, кто вошел в тотем (у игрока)
		var camera = body.get_node_or_null("Camera2D") 
		if camera:
			zoom_camera_out(camera)

func zoom_camera_out(cam: Camera2D):
	var tween = create_tween()
	# Плавное изменение зума до 0.6 за 2 секунды
	# Используем TRANS_SINE для мягкого начала и конца движения
	tween.tween_property(cam, "zoom", Vector2(0.6, 0.6), 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func start_rave_effect():
	var tween = create_tween().set_loops()
	# Анимируем радугу
	tween.tween_property(sprite_god.material, "shader_parameter/hue_variation", 1.0, 2.0).from(0.0)
