extends Area2D

@onready var banknota = $banknota

const DialogScene = preload("res://shop/shop.tscn")  
var dialog_instance = null

func _ready() -> void:
	body_entered.connect(body_in_shop)
	body_exited.connect(body_out_shop)
	Signals.connect("player_dialog_knopka", Callable(self, "_on_e_pressed"))
	
func body_in_shop(body: Node) -> void:
	if body.name == "CharacterBody2D":
		print("Добро пожаловать в магазин")
		banknota.visible = true


func body_out_shop(body: Node) -> void:
	if body.name == "CharacterBody2D":
		banknota.visible = false
		if dialog_instance:
			dialog_instance.queue_free()
		
		
func _on_e_pressed() -> void:
	print("Магазин получил сигнал от игрока")
	
	if dialog_instance == null:
		open_shop()
	
	else:
		close_shop()
	
func open_shop():
	print("Открываю магазин")
	dialog_instance = DialogScene.instantiate()
	get_tree().get_root().add_child(dialog_instance)


func close_shop():
	
	if dialog_instance:
		dialog_instance.queue_free()
		dialog_instance = null
	
