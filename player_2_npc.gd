extends CharacterBody2D

enum {
	IDLE,
	CHASE
}

var state: int = IDLE:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			CHASE:
				chase_state()
			
@onready var sprite = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var dial = $Dialog/dial
@onready var idicator = $Dialog/ramka
@onready var animPlayerE = $Dialog/ramka/e/AnimationPlayer
@onready var click = $Dialog/ramka/e

const DialogScene = preload("res://Dialog/dialog_ui.tscn")  
var dialog_instance = null

				
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player 
var direction

func _ready() -> void:
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	Signals.connect("player_dialog_knopka", Callable(self, "_on_e_pressed"))
	$Dialog.area_entered.connect(_on_dialog_area_entered)
	$Dialog.area_exited.connect(_on_dialog_area_exited)
	idicator.visible = false
	dial.visible = true
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
	
func _on_player_position_update(player_pos):
	player = player_pos
	if state == IDLE:
		update_rotation()
	
func idle_state():
	animPlayer.play("idle")
	velocity.x = 0
	# При входе в idle сразу поворачиваемся к игроку
	if player != null:
		update_rotation()

func chase_state():
	# Если нужно преследование, добавьте логику здесь
	pass

func update_rotation():
	if player == null:
		return
		
	direction = (player - global_position).normalized()
	
	# Правильная логика поворота спрайта
	if direction.x > 0:
		sprite.flip_h = false  # Смотрит вправо (игрок справа)
	else:
		sprite.flip_h = true   # Смотрит влево (игрок слева)


func _on_dialog_area_entered(area: Area2D) -> void:
	dial.visible = false
	idicator.visible = true
	print("Доступные анимации в AnimationPlayer:")
	animPlayerE.play("click")
	print("Начать беседу")
	

		
func _on_dialog_area_exited(area: Area2D) -> void:
	idicator.visible = false
	dial.visible = true
	print("Игрок вышел из зоны")
	close_dialog()
	
func _on_e_pressed() -> void:
	print("🔘 NPC: получен сигнал нажатия E")
	
	# Проверяем, что игрок в НАШЕЙ зоне
	if idicator.visible:
		print("✅ Игрок в моей зоне - переключаю диалог")
		
		if dialog_instance == null:
			open_dialog()
		else:
			close_dialog()
	else:
		print("❌ Игрок не в моей зоне - игнорирую")
		
func open_dialog():
	print("📖 Открываю диалог...")
	
	# Создаем экземпляр сцены
	dialog_instance = DialogScene.instantiate()
	
	# Добавляем на сцену (в корень)
	get_tree().get_root().add_child(dialog_instance)
	
	# Устанавливаем текст
	set_dialog_text("Привет! Я NPC.")
	
	print("✅ Диалог открыт")
func close_dialog():
	print("📖 Закрываю диалог...")
	
	if dialog_instance:
		dialog_instance.queue_free()
		dialog_instance = null
	
	print("✅ Диалог закрыт")
	
func set_dialog_text(text: String):
	if dialog_instance:
		# Получаем Label из созданной сцены
		var label = dialog_instance.get_node("Panel/Label") as Label
		if label:
			label.text = text
			print("Текст установлен: ", text)	
