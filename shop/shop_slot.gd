extends ColorRect

@onready var item_icon = %ItemIcon
@onready var description = %description

func display_item(item):
	if item:
		item_icon.texture = load("res://art/icon/%s" % item.icon) # Загружаем и устанавливаем иконку предмета в UI
		description.text = str(item.description) # Загружаем и устанавливаем Опписание предмета
	else:
		item_icon.texture = null
		description.text = ""
