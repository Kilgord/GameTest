extends Node

signal items_changed(indexes)

var cols: int = 11
var rows: int = 6
var slots: int = cols * rows
var items: Array = []
var n = 0

func _ready():
	for i in range(slots):
		items.append({})
	Signals.add_inventar.connect(add_inventary)
	
	
func add_inventary(cart):
	var changed_indexes = []
	for keys in Global.items.keys():
		var item_name = Global.items[keys]["name"]
		if item_name in cart:
			print(item_name)
			print(cart[item_name])
			items[n] = Global.get_item_by_key(keys)
			changed_indexes.append(n)
			n+=1
	if not changed_indexes.is_empty():
		items_changed.emit(changed_indexes)	

		
		
func set_item(index, item):
	var previos_item = items[index]
	items[index] = item
	items_changed.emit([index])
	return previos_item

func remove_item(index):
	var previos_item = items[index].duplicate()
	items[index].clear()
	items_changed.emit([index])
	return previos_item

func set_item_quantity(index, amount):
	items[index].quantity += amount
	if items[index].quantity <= 0:
		remove_item(index)
	else:
		items_changed.emit([index])
