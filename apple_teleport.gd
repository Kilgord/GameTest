extends Area2D

# Укажите путь к сцене, на которую нужно перейти
@export var target_scene: String = "res://node_2d.tscn"

func _ready():
	# Автоматически соединяем сигнал "body_entered" с функцией "_on_body_entered"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# Проверяем, что в зону вошёл именно игрок (узел из группы "player")
	if body.is_in_group("Playes"):
		# Мгновенно меняем сцену
		get_tree().change_scene_to_file(target_scene)
