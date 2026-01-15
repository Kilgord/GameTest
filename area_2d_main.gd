extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	print("Триггерная зона готова")
	
func _on_area_entered(area: Area2D) -> void:
	print("Обнаружена область:", area.name)
	if area.name == "HurtBox":
		print("Персонаж зашел")
		# Обращаемся к нашему глобальному скрипту
		SceneChanger.change_scene("res://scene_2.tscn")
