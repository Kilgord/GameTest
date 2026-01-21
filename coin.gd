extends Area2D

@onready var coin = $".."
@onready var coin_add = $coin_sbor

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("Триггерная зона готова")
	
func _on_body_entered(body: Node) -> void:
	print("Обнаружена область:", body.name)
	if body.name == "CharacterBody2D":
		coin.visible = false
		set_deferred("monitoring", false)
		coin_add.play()
		await coin_add.finished
		coin.queue_free()
		# Обращаемся к нашему глобальному скрипту
		#SceneChanger.change_scene("res://scene_2.tscn")
