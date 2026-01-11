extends CanvasLayer

@onready var gold_label = $Panel/VBoxContainer/HBoxContainer/GoldLabel
@onready var grid_container = $Panel/VBoxContainer/GridContainer
@onready var close_button = $Panel/VBoxContainer/CloseButton

# Сцена ячейки
const SLOT_SCENE = preload("res://Inventar/inventory_slot.tscn")
var slots: Array = []
var selected_slot: int = -1

func _ready() -> void:
	print("📦 UI инвентаря загружен")
	
	# Делаем весь инвентарь активным во время паузы
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	await get_tree().process_frame
	
	if InventoryManagerE:
		print("✅ InventoryManagerE найден")
	else:
		print("❌ InventoryManagerE НЕ найден!")
		return
	
	hide()
	create_slots()
	close_button.pressed.connect(_on_close_button_pressed)
	
	InventoryManagerE.inventory_changed.connect(_on_inventory_changed)
	InventoryManagerE.gold_changed.connect(_on_gold_changed)
	
	# Автоматически открываем для теста
	open()

func create_slots():
	print("\n=== СОЗДАНИЕ СЛОТОВ ===")
	
	for i in range(20):
		var slot = SLOT_SCENE.instantiate()
		slot.name = "Slot_%d" % i
		
		# Делаем слоты активными во время паузы
		slot.process_mode = Node.PROCESS_MODE_ALWAYS
		
		if slot.has_method("set_index"):
			slot.set_index(i)
		
		if slot.has_signal("slot_clicked"):
			slot.slot_clicked.connect(_on_slot_clicked)
		
		grid_container.add_child(slot)
		slots.append(slot)
	
	print("✅ Все слоты созданы")
	
	# Тестовые цветные квадраты
	if slots.size() > 0:
		slots[0].get_node("Icon").texture = create_simple_texture(Color.RED)
	if slots.size() > 1:
		slots[1].get_node("Icon").texture = create_simple_texture(Color.GREEN)
	if slots.size() > 2:
		slots[2].get_node("Icon").texture = create_simple_texture(Color.BLUE)

func create_simple_texture(color: Color) -> Texture2D:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

func update_slot(slot_index: int):
	if slot_index >= slots.size():
		return
	
	var slot = slots[slot_index]
	var icon_node = slot.get_node("Icon")
	
	if InventoryManagerE and InventoryManagerE.has_item_at(slot_index):
		var item_data = InventoryManagerE.get_item_at(slot_index)
		if not item_data.is_empty():
			icon_node.texture = item_data.get("icon", null)
	else:
		icon_node.texture = null

func _on_slot_clicked(slot_index: int):
	print("🎯 Клик по слоту", slot_index)
	
	if InventoryManagerE and InventoryManagerE.has_item_at(slot_index):
		var item = InventoryManagerE.get_item_at(slot_index)
		print("📦 В слоте", slot_index, " находится:", item.get("name", "Без имени"))
		select_slot(slot_index)
	else:
		print("📭 Слот", slot_index, " пуст")

func select_slot(slot_index: int):
	if selected_slot >= 0 and selected_slot < slots.size():
		var old_slot = slots[selected_slot]
		if old_slot.has_node("Background"):
			old_slot.get_node("Background").modulate = Color.WHITE
	
	selected_slot = slot_index
	if slot_index < slots.size():
		var new_slot = slots[slot_index]
		if new_slot.has_node("Background"):
			new_slot.get_node("Background").modulate = Color.YELLOW

func _on_inventory_changed():
	print("🔄 Инвентарь изменился")
	for i in range(slots.size()):
		update_slot(i)

func _on_gold_changed(new_amount: int):
	gold_label.text = "Золото: %d" % new_amount

# Обработка ESC
func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		print("Закрытие по ESC")
		close()

func _on_close_button_pressed():
	print("❌ Кнопка закрытия нажата!")
	close()

func open():
	print("📖 Открываю инвентарь")
	show()
	get_tree().paused = true
	
	# Даем фокус кнопке
	close_button.grab_focus()
	
	# Обновляем данные
	gold_label.text = "Золото: %d" % InventoryManagerE.gold
	for i in range(slots.size()):
		update_slot(i)

func close():
	print("📕 Закрываю инвентарь")
	hide()
	get_tree().paused = false
