extends Area2D

func _ready() -> void:
	# Здесь "self" (этот Area2D) подключает СВОЙ сигнал к СВОЕЙ функции
	self.area_entered.connect(_on_area_entered)



func _on_area_entered(area: Area2D) -> void:
	print("Поговорить")
