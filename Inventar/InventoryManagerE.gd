# InventoryManagerE.gd - УПРОЩЕННАЯ ВЕРСИЯ
extends Node

signal inventory_changed
signal gold_changed

var gold: int = 100
var inventory: Array = []
var inventory_size: int = 20

func _ready():
	print("=== INVENTORY MANAGER ЗАГРУЖЕН ===")
	
	# Инициализируем пустой инвентарь
	inventory.resize(inventory_size)
	for i in range(inventory_size):
		inventory[i] = null
	
	# СОЗДАЕМ ПРОСТЫЕ ТЕКСТУРЫ
	var red_texture = create_simple_texture(Color.RED)
	var green_texture = create_simple_texture(Color.GREEN)
	
	print("Красная текстура создана:", red_texture != null)
	print("Зеленая текстура создана:", green_texture != null)
	
	# Добавляем тестовые предметы
	add_item_to_inventory({
		"id": "sword",
		"name": "Меч",
		"icon": preload("res://Inventar/icon/idle.png"),
		"quantity": 1,
		"stackable": false,
		"description": "Острый стальной меч"
	})
	
	add_item_to_inventory({
		"id": "potion",
		"name": "Зелье здоровья", 
		"icon": preload("res://Inventar/icon/Fall.png"),
		"quantity": 3,
		"stackable": true,
		"description": "Восстанавливает здоровье"
	})
	
	print("✅ Предметы добавлены в слоты 0 и 1")

# Простая функция для создания текстуры
func create_simple_texture(color: Color) -> Texture2D:
	print("Создаю текстуру цвета:", color)
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	print("Текстура создана, размер:", texture.get_size())
	return texture

# Проверяет, есть ли предмет в указанном слоте
func has_item_at(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= inventory.size():
		return false
	return inventory[slot_index] != null

# Возвращает предмет из указанного слота
func get_item_at(slot_index: int) -> Dictionary:
	if has_item_at(slot_index):
		return inventory[slot_index]
	return {}

# Добавляет предмет в инвентарь
func add_item_to_inventory(item_data: Dictionary):
	# Если предмет стакается, ищем существующий стек
	if item_data.get("stackable", false):
		for i in range(inventory.size()):
			if inventory[i] != null and inventory[i].get("id") == item_data["id"]:
				inventory[i]["quantity"] += item_data.get("quantity", 1)
				inventory_changed.emit()
				return
	
	# Ищем пустой слот
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item_data
			print("✅ Предмет добавлен в слот", i)
			inventory_changed.emit()
			return
	
	print("Инвентарь полен!")

# Удаляет предмет из слота
func remove_item_from_slot(slot_index: int):
	if has_item_at(slot_index):
		inventory[slot_index] = null
		inventory_changed.emit()

# Изменяет количество золота
func add_gold(amount: int):
	gold += amount
	gold_changed.emit(gold)

func remove_gold(amount: int):
	gold = max(0, gold - amount)
	gold_changed.emit(gold)
