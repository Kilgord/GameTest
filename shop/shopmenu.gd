extends GridContainer
class_name ContainerSlot

var ItemSlot = load("res://shop/shop_slot.tscn")
var slots


func display_item_slot(cols: int, rows: int):
	var item_slot
	columns = cols  #Сохраняю количество колонок
	slots = cols * rows # Вычисляю общее количество слотов
	
	for index in range(slots):
		item_slot = ItemSlot.instantiate()
		add_child(item_slot)
		item_slot.display_item(ShopInventar.items[index])
	ShopInventar.items_changed.connect(_on_Inventory_items_changed)

func _on_Inventory_items_changed(indexes):
	var item_slot
	
	# Обновляю только измененные слоты
	for index in indexes:
		if index < slots: # Проверяю что индекс в пределах
			item_slot = get_child(index) # Получаю слот
			item_slot.display_item(ShopInventar.items[index]) # Обновляю данные
