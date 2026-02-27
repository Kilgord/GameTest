extends CanvasLayer

@onready var drag_preview = $Inventory/InventoryContainer/DragPreview

func _ready():
	for item_slot in get_tree().get_nodes_in_group("items_slot"):
		var index = item_slot.get_index()
		item_slot.connect("gui_input", _on_ItemSlot_gui_input.bind(index))

func _on_ItemSlot_gui_input(event, index):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if visible:
				print(index)
				drag_item(index)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			split_item(index)		

func drag_item(index):
	var inventory_item = Inventory.items[index]
	var dragged_item = drag_preview.dragged_item
	
  # Взять предмет
	if inventory_item && !dragged_item:
		drag_preview.dragged_item = Inventory.remove_item(index)
  # Бросить предмет
	if !inventory_item && dragged_item:
		drag_preview.dragged_item = Inventory.set_item(index, dragged_item)
	if inventory_item && dragged_item:
	# Стакнуть предмет
		if inventory_item.key == dragged_item.key && inventory_item.stackable:
			Inventory.set_item_quantity(index, dragged_item.quantity)
			drag_preview.dragged_item = {}
		# Свапнуть предмет
		else:
			drag_preview.dragged_item = Inventory.set_item(index, dragged_item)

func split_item(index):
	var inventory_item = Inventory.items[index]
	var dragged_item = drag_preview.dragged_item
	var split_amount
	var item
  
  # Проверяем если предмет стакабл
	if !inventory_item || !inventory_item.stackable: return
	split_amount = ceil(inventory_item.quantity / 2.0)
	
	if dragged_item && inventory_item.key == dragged_item.key:
		drag_preview.dragged_item.quantity += split_amount
		Inventory.set_item_quantity(index, -split_amount)
	if !dragged_item:
		item = inventory_item.duplicate()
		item.quantity = split_amount
		drag_preview.dragged_item = item
		Inventory.set_item_quantity(index, -split_amount)

func open():
	visible = true

func close():
	visible = !visible
