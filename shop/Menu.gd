extends ContainerSlot
@onready var btn_buy = $"../TextureButton"


func _ready():
	display_item_slot(ShopInventar.cols, ShopInventar.rows) #  Создает слоты магазина
	#position = (get_viewport_rect().size - size) / 2 # Центрирует окно
	


func _on_texture_button_pressed() -> void:
	Signals.emit_signal("buy_pressed")
