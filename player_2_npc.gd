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
				
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player 
var direction

func _ready() -> void:
	Signals.connect("player_position_update", Callable(self, "_on_player_position_update"))

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
