extends CharacterBody2D

signal health_change(new_health)

enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	DEATH,
	DAMAGE
	
}

const SPEED = 100.0
const JUMP_VELOCITY = -250.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
var max_health = 100
var health
var gold = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos
var damage_basic = 10
var damage_multiplier = 1
var damage_current 

func _ready() -> void:
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received"))
	health = max_health

func _physics_process(delta: float) -> void:
		
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_stae()
		ATTACK3:
			attack3_stae()
		BLOCK:
			block_state()
		DEATH:
			death_state()	
		DAMAGE:
			damage_state()
						
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if velocity.y > 0:
		animPlayer.play("falen")
	damage_current = damage_basic * damage_multiplier

		
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)
	
	
func move_state ():
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("walk")
			else:
				animPlayer.play("Run")	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("idle")	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("jump")
				
	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if velocity.y > 0:
		anim.play("falen")	
	if Input.is_action_pressed("Run"):
		run_speed = 2
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		state = BLOCK	
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK	
		
		
		
		
		
func block_state ():
	velocity.x = 0
	animPlayer.play("block")
	if Input.is_action_just_released("block"):
		state = MOVE
func attack_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func attack2_stae ():
	damage_multiplier = 1.2
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animPlayer.play("attack2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack3_stae ():
	damage_multiplier = 2
	animPlayer.play("attack3")
	await animPlayer.animation_finished
	state = MOVE
			
func combo1 ():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack_freeze ():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func death_state ():
	velocity.x = 0
	var scene_tree = get_tree()
	animPlayer.play("deathplayer")
	await animPlayer.animation_finished
	queue_free()
	scene_tree.change_scene_to_file("res://main_menu.tscn")
	
func damage_state ():
	velocity.x = 0
	animPlayer.play("damage")
	await animPlayer.animation_finished
	state = MOVE
		

	
func _on_damage_received (enemy_damage):
	if  state == BLOCK:
		enemy_damage /= 2	
	else:	
		state = DAMAGE
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH
	
	emit_signal("health_change", health)
	


func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("player_attack", damage_current)
