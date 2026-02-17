extends Node

signal items_changed(indexes)

var cols: int = 1
var rows: int = 3
var slots: int = cols * rows
var items: Array = []
var cart = {}


func _ready() -> void:
	for i in range(slots):
		items.append({})
		items[i] = Global.get_item_by_key(Global.key_items[i])
	Signals.connect("buy_pressed", Callable(self, "item_for_buy"))	
	Signals.add_cart.connect(cart_add)

func cart_add(name_item,count):
	cart[name_item] = count
	
	
func item_for_buy():
	if cart == null:
		print("Пусто")
	else:
		Signals.emit_signal("add_inventar", cart)
		print(cart) 
		cart = {}
		
		
func set_item(index, item):
	var previos_item = items[index] # Сохраняем старый предмет
	items[index] = item  # Заменяем на новый
	items_changed.emit([index]) # Сигнализируем об изменении
	return previos_item		# Возвращаем старый предмет

func remove_item(index):
	var previos_item = items[index].duplicate() # Копируем предмет
	items[index].clear() # Очищаем слот
	items_changed.emit([index]) # Сигнал об изменении
	return previos_item # Возвращаем копию

func set_item_quantity(index, amount):
	items[index].quantity += amount # Изменяем количество
	if items[index].quantity <= 0: # Проверяем не закончилось ли
		remove_item(index) 	 # Удаляем если <= 0
	else:
		items_changed.emit([index]) # Иначе сигнал об изменении
