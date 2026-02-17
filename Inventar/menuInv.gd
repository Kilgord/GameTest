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

func drag_item(index):
	var inventory_item = Inventory.items[index]
	var dragged_item = drag_preview.dragged_item
	
  # Взять предмет
	if inventory_item && !dragged_item:
		drag_preview.dragged_item = Inventory.remove_item(index)
  # Бросить предмет
	if !inventory_item && dragged_item:
		drag_preview.dragged_item = Inventory.set_item(index, dragged_item)
  # Свапнуть предмет
	if inventory_item and dragged_item:
		drag_preview.dragged_item = Inventory.set_item(index, dragged_item)

func open():
	visible = true

func close():
	visible = !visible
