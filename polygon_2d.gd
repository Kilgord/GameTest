extends Polygon2D

@export var player_node: Node2D
@export var segments_x: int = 50  # Вершин по ширине
@export var segments_y: int = 3   # Вершин по высоте

func _ready():
	# Размер поля (как у твоего TextureRect)
	var width = 990
	var height = 107
	
	# Создаем массивы для точек и UV
	var points_array = PackedVector2Array()
	var uvs_array = PackedVector2Array()
	
	# Создаем сетку вершин
	for y in range(segments_y + 1):
		for x in range(segments_x + 1):
			# Вычисляем позицию вершины
			var x_pos = (float(x) / segments_x) * width
			var y_pos = (float(y) / segments_y) * height
			
			points_array.append(Vector2(x_pos, y_pos))
			
			# UV координаты (для тайлинга)
			var u = float(x) / segments_x
			var v = float(y) / segments_y
			uvs_array.append(Vector2(u, v))
	
	# Устанавливаем полигон
	self.polygon = points_array
	self.uv = uvs_array
	
	# Включаем повторение текстуры (тайлинг)
	self.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	# Масштаб как у тебя был
	self.scale = Vector2(0.5, 0.5)
	
	# Позиционируем как нужно
	# self.position = Vector2(100, 200)  # Если нужно
	
	print("✅ Polygon created successfully!")
	print("   Points: ", points_array.size())
	print("   Size: ", width, "x", height)
	print("   Texture: ", "Loaded" if self.texture else "None")

func _process(delta):
	if player_node and material:
		# Получаем позицию игрока
		var p_pos = player_node.get_global_transform_with_canvas().origin
		
		# Корректируем высоту (к ногам)
		p_pos.y += 100
		
		# Передаем в шейдер
		material.set_shader_parameter("player_global_pos", p_pos)
