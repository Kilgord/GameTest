extends Control

signal slot_clicked(slot_index: int)

var slot_index: int = 0

func _ready():
	# Важно: делаем слот всегда активным
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Находим кнопку и подключаем сигнал
	var slot_button = get_node_or_null("SlotButton")
	if slot_button:
		# Делаем кнопку всегда активной
		slot_button.process_mode = Node.PROCESS_MODE_ALWAYS
		slot_button.pressed.connect(_on_slot_button_pressed)
		print("✅ Кнопка подключена для слота", slot_index)

func set_index(index: int):
	slot_index = index
	print("Установлен индекс слота:", slot_index)

func _on_slot_button_pressed():
	print("🎯 Кнопка слота", slot_index, " нажата!")
	emit_signal("slot_clicked", slot_index)

func set_highlighted(highlight: bool):
	# Меняем визуальное выделение слота
	var background = get_node_or_null("Background")
	if background:
		if highlight:
			background.modulate = Color.YELLOW
		else:
			background.modulate = Color.WHITE
