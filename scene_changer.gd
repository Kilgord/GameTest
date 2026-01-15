extends Node

# Ссылка на аниматор. Проверь, чтобы имя совпало с твоим (на фото это fade_in)


func change_scene(target_scene_path: String):
	print(target_scene_path)
	# 1. Запускаем анимацию закрытия
	$CanvasLayer/fade_in.play("fade_in")
 
# 2. Ждем окончания анимации (экран стал черным)
	await $CanvasLayer/fade_in.animation_finished
	print("Готово")
 # 3. Меняем сцену
	get_tree().change_scene_to_file(target_scene_path)
	await get_tree().process_frame
	# 4. Проигрываем анимацию открытия (создай её, если еще нет)
	$CanvasLayer/fade_in.play("fade_out")
