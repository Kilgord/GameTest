extends TextureRect

@export var player_node: Node2D 

func _process(_delta):
	if player_node and material:
		# Получаем экранную позицию игрока
		# (она всегда совпадает с тем, что мы видим глазами)
		var p_pos = player_node.get_global_transform_with_canvas().origin
		
		# Сдвигаем точку к ногам рыцаря
		p_pos.y += 100 
		
		material.set_shader_parameter("player_global_pos", p_pos)
