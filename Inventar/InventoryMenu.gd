extends InventarSlot

func _ready():
  display_item_slot(Inventory.cols, Inventory.rows)
  #position = (get_viewport_rect().size - size) / 2
