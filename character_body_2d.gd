extends CharacterBody2D



enum {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	DEATH,
	DAMAGE,
	BLOCKACTIVE,
	FIRE
	
}

const SPEED = 80.0
const ACCEL = 200.0  # Ускорение для плавного старта
const DECEL = 800.0  # Торможение
const JUMP_VELOCITY = -260.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var stats = $stats
@onready var smack = $Sounds/Smack
@onready var inventory_ui = preload("res://Inventar/scene/Menu.tscn")
@onready var player = $"."
@onready var door = $"../../Sprite2D"
@onready var camera = $Camera2D
@onready var box = $"../../box"
@onready var ui_label = $ui


var gold = 0
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos
var damage_basic = 10
var damage_multiplier = 1
var damage_current 
var jump_count = 0
var max_jumps = 2
var can_double_jump = false
var recovery = false
var near_npc = false
var current_npc_area = null
var inventory_instance = null


func _ready() -> void:
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received"))
	Signals.sobral_vse.connect(scripte_scene)
	print("🎮 Для теста нажмите:")
	print("   - E (ваша кнопка)")
	print("   - ПРОБЕЛ (стандартная)")
	print("   - ENTER")
	print("   - ЛКМ (мышь)")
	

		
func _physics_process(delta: float) -> void:
		
	match state:
		MOVE:
			move_state(delta)	
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
		BLOCKACTIVE:
			block_active_state()
		FIRE:
			fire_state()				
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	
	damage_current = damage_basic * damage_multiplier

	
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)
	
	
func move_state(delta: float):
	var chat_nodes = get_tree().get_nodes_in_group("chat_system")
	for chat in chat_nodes:
		if chat.chat_active and chat.message_input.has_focus():
			print("Движение заблокировано: активен чат")
			return
			
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		var target_speed = direction * SPEED * run_speed
		velocity.x = move_toward(velocity.x, target_speed, ACCEL * delta)
		
		if velocity.y == 0:
			# Анимация зависит от текущей скорости
			var speed_percent = abs(velocity.x) / (SPEED * run_speed)
			
			if speed_percent > 0.8:  # Высокая скорость
				if run_speed > 1:
					animPlayer.play("Run")
				else:
					animPlayer.play("walk")
			elif speed_percent > 0.1:  # Средняя/низкая скорость
				animPlayer.play("walk")
			else:  # Очень медленно
				animPlayer.play("idle")
				
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)
		
		if velocity.y == 0:
			if abs(velocity.x) < 5:  # Почти остановился
				animPlayer.play("idle")
			else:  # Ещё катится по инерции
				animPlayer.play("walk")
			
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
			animPlayer.play("jump")
			can_double_jump = true
		elif can_double_jump and jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY
			jump_count +=1
			can_double_jump = false
			animPlayer.play("jump")		
	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if velocity.y > 0:
		animPlayer.play("falen")	
		
	if Input.is_action_pressed("Run") and not recovery:
		run_speed = 2
		stats.energy -= stats.run_cost
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		state = BLOCK
	if Input.is_action_just_pressed("attack"):
		if not recovery:
			stats.energy_cost = stats.attack_cost
			stats.energy -= stats.energy_cost
			if attack_cooldown == false and stats.energy > stats.energy_cost:
				state = ATTACK
		
		
	
		
#super testing
func fire_state ():
	print("fire")	
		
func block_state ():
	velocity.x = 0
	animPlayer.play("block")
	if Input.is_action_just_released("block"):
		state = MOVE
		
func block_active_state ():
	if not recovery:
		stats.energy -= stats.block_cost
		animPlayer.play("block_active")
		await animPlayer.animation_finished
		state = MOVE
	
func attack_state():
	stats.energy_cost = stats.attack_cost
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") and combo == true and stats.energy > stats.energy_cost:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func attack2_stae ():
	stats.energy_cost = stats.attack_cost
	damage_multiplier = 1.2
	if Input.is_action_just_pressed("attack") and combo == true and stats.energy > stats.energy_cost:
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
	smack.play()
	if  state == BLOCK:
		enemy_damage /= 2
		print(enemy_damage)
		if enemy_damage == 10:
			print("pipaka")
			state = BLOCKACTIVE
			
	else:	
		state = DAMAGE
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH
	
	
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	Signals.emit_signal("player_attack", damage_current)
	

func _on_stats_no_energy() -> void:
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false


			
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.name == "Dialog" or area.is_in_group("npc_dialog"):
		near_npc = true
		current_npc_area = area
		print("✅ Рядом с NPC!")
		print("   Нажмите E для диалога")
	elif area.name == "Shop":
		near_npc = true
		print("Я у магазина")
	
func _on_hurt_box_area_exited(area: Area2D) -> void:
	print("\n🎮 Выход из зоны:", area.name)
	
	if area.name == "Dialog" or area.is_in_group("npc_dialog"):
		near_npc = false
		current_npc_area = null
		print("🚶 Отошел от NPC")
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	# 1. ПРЯМАЯ ПРОВЕРКА КЛАВИШИ E (ВСЕГДА РАБОТАЕТ)
	if event is InputEventKey and event.keycode == KEY_E and event.pressed and not event.echo:
		print("\n🎮 НАЖАТИЕ КЛАВИШИ E")
		check_and_send_signal()
		return  # Выходим, чтобы не проверять дальше
	
	# 2. Проверка действия (только если оно существует)
	if InputMap.has_action("open_dialog"):
		if event.is_action("open_dialog") and event.is_pressed():
			print("\n🎮 ДЕЙСТВИЕ 'open_dialog'")
			check_and_send_signal()

func check_and_send_signal():
	print("   near_npc =", near_npc)
	
	if near_npc:
		print("   ✅ Отправляю сигнал player_dialog_knopka")
		Signals.emit_signal("player_dialog_knopka")
	else:
		print("   ❌ Игрок не рядом с NPC")


func _input_inventary(event: InputEvent) -> void:
	# Открыть инвентарь по I
	if event.is_action_just_pressed("inventory"):
		toggle_inventory()

func toggle_inventory() -> void:
	if inventory_instance and inventory_instance.visible:
		close_inventory()
	else:
		open_inventory()

func open_inventory() -> void:
	# Проверяем все узлы в группе чата
	var chat_nodes = get_tree().get_nodes_in_group("chat_system")
	for chat in chat_nodes:
		if chat.chat_active and chat.message_input.has_focus():
			print("Инвентарь заблокирован: активен чат")
			return
	
	print("Открываю инвентарь")
	
	if inventory_instance == null:
		inventory_instance = inventory_ui.instantiate()
		get_tree().get_root().add_child(inventory_instance)
	
	inventory_instance.open()

func close_inventory() -> void:
	print("Закрываю инвентарь")
	
	if inventory_instance:
		inventory_instance.close()

func scripte_scene():
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	animPlayer.play("idle")
	
	var original_camera_pos = camera.global_position
	
	var tween = create_tween().set_parallel(false)
	var door_position  = door.global_position
	tween.tween_property(camera, "global_position", door_position, 1.5)
	await tween.finished
	
	box.visible = true
	await get_tree().create_timer(1.0).timeout
	
	var tween_back = create_tween()
	tween_back.tween_property(camera, "global_position", original_camera_pos, 1.0)
	await tween_back.finished
	
	ui_label.text = "Вы собрали все монеты!"
	ui_label.show()
	await get_tree().create_timer(5.0).timeout
	ui_label.hide() 
	
	player.set_physics_process(true)
