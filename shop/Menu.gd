extends ContainerSlot

func _ready():
  display_item_slot(ShopInventar.cols, ShopInventar.rows) #  Создает слоты магазина
  position = (get_viewport_rect().size - size) / 2 # Центрирует окно
