extends ColorRect

@onready var item_icon = %ItemIcon
@onready var description = %description
@onready var price = %price_for_one
@onready var count = %count
@onready var btnup = $fontbuttons/buttonup
@onready var btndown = $fontbuttons/buttondown
@onready var priceall = $price_for_all



var count_new = 0
var price_all = 0
var item_name
	
	
	
func display_item(item):
		if item:
				item_icon.texture = load("res://art/icon/%s" % item.icon)
				item_name = item.name
				description.text = str(item.description) # Загружаем и устанавливаем Опписание предмета
				#item_icon.scale = Vector2(0.5, 0.5)
				price.text = str(int(item.price))# Загружаем и устанавливаем цену за 1 ед. предмета
				count.text = str(int(count_new))
				priceall.text = str(int(price_all))
		else:
				item_icon.texture = null
				description.text = ""




func _on_buttonup_pressed() -> void:
		count_new+=1
		count.text = str(int(count_new))
		price_all = int(price.text)*count_new
		priceall.text = str(int(price_all))
		Signals.emit_signal("add_cart",item_name, count_new)
	
		
func _on_buttondown_pressed() -> void:
		count_new-=1
		if int(count_new) <= -1:
				count_new = 0
				count.text = str(int(count_new))
		else:
				count.text = str(int(count_new))
				price_all-=int(price.text)
				priceall.text = str(int(price_all))
				Signals.emit_signal("add_cart",item_name, count_new)
