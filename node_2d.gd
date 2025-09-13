extends Node2D
@onready var light = $DirectionalLight2D
@onready var pointlight = $PointLight2D
@onready var animPlayer = $CanvasLayer/AnimationPlayer
@onready var healt_bar = $CanvasLayer/HealthBar
@onready var player = $Player/CharacterBody2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING

func _ready() -> void:
	healt_bar.max_value = player.max_health
	healt_bar.value = healt_bar.max_value
	light.enabled = true


	
			
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


func _on_character_body_2d_health_change(new_health: Variant) -> void:
	healt_bar.value = new_health
