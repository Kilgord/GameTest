extends Node2D
@onready var light = $DirectionalLight2D
@onready var pointlight = $PointLight2D
@onready var animPlayer = $CanvasLayer/AnimationPlayer
@onready var player = $Player/CharacterBody2D


enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING


func _ready() -> void:
	light.enabled = true
	# Ждем один кадр, чтобы TileMap успел расставить сцены монет
	await get_tree().process_frame 
	
	var coins_nodes = get_tree().get_nodes_in_group("coin")
	var total_coins = coins_nodes.size()
	print("Всего монет-объектов на уровне: ", total_coins)
	Signals.all_coins.emit(total_coins)

	
			
func morning_state ():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.2, 20)
	animPlayer.play("text")
	await get_tree().create_timer(3).timeout
	animPlayer.play("text_vse")			
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 0, 20)
					
func evening_state ():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 20)		
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointlight, "energy", 0.5, 20)
	
func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state ()
		EVENING:
			evening_state ()
	if state < 3:
		state += 1
	else:
		state = MORNING
