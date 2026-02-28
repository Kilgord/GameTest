extends CanvasLayer
signal coins_updated(new_total)
signal no_energy ()

@onready var health_bar = $HealthBar
@onready var energy_bar = $Energy
@onready var gold_bar = $coins/gold_staatus
@onready var all_coins_stat = $all_coins/status

var energy_cost
var attack_cost = 10
var block_cost = 1
var run_cost = 1
var all_c

	

var energy = 700:
	set(value):
		energy = value
		if energy < 1:
			emit_signal("no_energy")
			
var max_health = 100
var health:
	set(value):
		health = value
		health_bar.value = health

func _ready() -> void:
	Signals.get_gold.connect(gold_get)
	Signals.all_coins.connect(all_coins)
	connect("coins_updated", update_coins)
	health = max_health
	health_bar.max_value = health
	health_bar.value = health
	
	
func _process(delta: float) -> void:
	energy_bar.value = energy
	if energy < 100:
		energy += 10 * delta

func energy_consuption ():
	energy -= energy_cost

func gold_get(coins):
	var coin = coins
	gold_bar.text = str(coin)
	emit_signal("coins_updated", coin)
	
func all_coins(total_coins):
	all_c = total_coins
	all_coins_stat.text = str(all_c)
	
func update_coins(coin):
	var itog = all_c - coin
	all_coins_stat.text = str(itog)
	if itog == 133:
		Signals.sobral_vse.emit()
	
