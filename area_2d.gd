extends Area2D
func _on_body_entered(body):
 if body is CharacterBody2D:
  # Обращаемся к нашему глобальному скрипту
  SceneChanger.change_scene("res://node_2d.tscn")
