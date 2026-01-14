extends CanvasLayer

# Ссылка на аниматор. Проверь, чтобы имя совпало с твоим (на фото это fade_in)
@onready var animation_player = $fade_in 

func change_scene(target_scene_path: String):
 # 1. Запускаем анимацию закрытия
 animation_player.play("fade_in")
 
 # 2. Ждем окончания анимации (экран стал черным)
 await animation_player.animation_finished
 
 # 3. Меняем сцену
 get_tree().change_scene_to_file(target_scene_path)
 
 # 4. Проигрываем анимацию открытия (создай её, если еще нет)
 animation_player.play("fade_out")
